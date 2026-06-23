// See LICENSE.Berkeley for license details.

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cstdio>
#include <cstdlib>

#include <sys/socket.h>

#include "remote_bitbang.h"


/////////// remote_bitbang_t

remote_bitbang_t::remote_bitbang_t(uint16_t port) :
  socket_fd(-1),
  client_fd(-1),
  recv_start(0),
  recv_end(0),
  err(0)
{
  socket_fd = socket(AF_INET, SOCK_STREAM, 0);
  if (socket_fd == -1) {
    fprintf(stderr, "remote_bitbang failed to make socket: %s (%d)\n",
            strerror(errno), errno);
    abort();
  }

  fcntl(socket_fd, F_SETFL, O_NONBLOCK);
  int reuseaddr = 1;
  if (setsockopt(socket_fd, SOL_SOCKET, SO_REUSEADDR, &reuseaddr,
                 sizeof(int)) == -1) {
    fprintf(stderr, "remote_bitbang failed setsockopt: %s (%d)\n",
            strerror(errno), errno);
    abort();
  }

  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = INADDR_ANY;
  addr.sin_port = htons(port);

  if (::bind(socket_fd, (struct sockaddr *) &addr, sizeof(addr)) == -1) {
    fprintf(stderr, "remote_bitbang failed to bind socket: %s (%d)\n",
            strerror(errno), errno);
    abort();
  }

  if (listen(socket_fd, 1) == -1) {
    fprintf(stderr, "remote_bitbang failed to listen on socket: %s (%d)\n",
            strerror(errno), errno);
    abort();
  }

  socklen_t addrlen = sizeof(addr);
  if (getsockname(socket_fd, (struct sockaddr *) &addr, &addrlen) == -1) {
    fprintf(stderr, "remote_bitbang getsockname failed: %s (%d)\n",
            strerror(errno), errno);
    abort();
  }

  tck = 1;
  tms = 1;
  tdi = 1;
  trstn = 1;
  quit = 0;

  fprintf(stderr, "JTAG remote-bitbang server enabled.\n");
  fprintf(stderr, "Listening on port %d\n",
         ntohs(addr.sin_port));
}

void remote_bitbang_t::accept()
{
  static bool printed_accept_attempt = false;
  if (!printed_accept_attempt) {
    fprintf(stderr, "Attempting to accept client socket\n");
    printed_accept_attempt = true;
  }

  client_fd = ::accept(socket_fd, nullptr, nullptr);

  if (client_fd == -1) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      // No OpenOCD client is waiting.
      // Return immediately so Questa can continue simulating.
      return;
    }

    if (errno == EINTR) {
      // Interrupted system call; simply try again on the next DPI tick.
      return;
    }

    fprintf(stderr,
            "failed to accept on socket: %s (%d)\n",
            strerror(errno),
            errno);
    abort();
  }

  const int flags = fcntl(client_fd, F_GETFL, 0);
  if (flags == -1 || fcntl(client_fd, F_SETFL, flags | O_NONBLOCK) == -1) {
    fprintf(stderr,
            "failed to set client socket non-blocking: %s (%d)\n",
            strerror(errno),
            errno);
    close(client_fd);
    client_fd = -1;
    abort();
  }

  fprintf(stderr, "Accepted OpenOCD connection successfully.\n");
}

void remote_bitbang_t::tick(
                            unsigned char * jtag_tck,
                            unsigned char * jtag_tms,
                            unsigned char * jtag_tdi,
                            unsigned char * jtag_trstn,
                            unsigned char jtag_tdo
                            )
{
  if (client_fd >= 0) {
    tdo = jtag_tdo;
    execute_command();
  } else {
    this->accept();
  }

  *jtag_tck = tck;
  *jtag_tms = tms;
  *jtag_tdi = tdi;
  *jtag_trstn = trstn;

}

void remote_bitbang_t::reset(){
  //trstn = 0;
}

void remote_bitbang_t::set_pins(char _tck, char _tms, char _tdi){
  tck = _tck;
  tms = _tms;
  tdi = _tdi;
}

void remote_bitbang_t::execute_command()
{
  char command;

  const ssize_t num_read =
      ::read(client_fd, &command, sizeof(command));

  if (num_read == -1) {
    if (errno == EAGAIN ||
        errno == EWOULDBLOCK ||
        errno == EINTR) {
      // OpenOCD currently has no new command.
      // Return control to SystemVerilog and try again on the next DPI tick.
      return;
    }

    fprintf(stderr,
            "remote_bitbang failed to read on socket: %s (%d)\n",
            strerror(errno),
            errno);

    close(client_fd);
    client_fd = -1;
    return;
  }

  if (num_read == 0) {
    // A zero-length read means that the peer closed the connection.
    fprintf(stderr, "OpenOCD disconnected.\n");

    close(client_fd);
    client_fd = -1;
    return;
  }

  int dosend = 0;

  char tosend = '?';

  switch (command) {
  case 'B': /* fprintf(stderr, "*BLINK*\n"); */ break;
  case 'b': /* fprintf(stderr, "_______\n"); */ break;
  case 'r': reset(); break; // This is wrong. 'r' has other bits that indicated TRST and SRST.
  case '0': set_pins(0, 0, 0); break;
  case '1': set_pins(0, 0, 1); break;
  case '2': set_pins(0, 1, 0); break;
  case '3': set_pins(0, 1, 1); break;
  case '4': set_pins(1, 0, 0); break;
  case '5': set_pins(1, 0, 1); break;
  case '6': set_pins(1, 1, 0); break;
  case '7': set_pins(1, 1, 1); break;
  case 'R': dosend = 1; tosend = tdo ? '1' : '0'; break;
  case 'Q': quit = 1; break;
  default:
    fprintf(stderr, "remote_bitbang got unsupported command '%c'\n",
            command);
  }

  if (dosend) {
    ssize_t num_written;

    do {
      num_written = ::send(client_fd,
                          &tosend,
                          sizeof(tosend),
                          MSG_NOSIGNAL);
    } while (num_written == -1 && errno == EINTR);

    if (num_written != static_cast<ssize_t>(sizeof(tosend))) {
      if (num_written == -1 &&
          (errno == EAGAIN || errno == EWOULDBLOCK)) {
        fprintf(stderr, "remote_bitbang socket temporarily not writable\n");
      } else if (num_written == -1) {
        fprintf(stderr,
                "remote_bitbang failed to write on socket: %s (%d)\n",
                strerror(errno),
                errno);
      } else {
        fprintf(stderr,
                "remote_bitbang short write on socket: %zd/%zu\n",
                num_written,
                sizeof(tosend));
      }

      close(client_fd);
      client_fd = -1;
      return;
    }
  }

  if (quit) {
    fprintf(stderr, "Remote end requested disconnect.\n");
    close(client_fd);
    client_fd = -1;
    quit = 0;
  }
}
