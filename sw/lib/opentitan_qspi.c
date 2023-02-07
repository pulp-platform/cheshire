// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef OPENTITAN_QSPI_C_
#define OPENTITAN_QSPI_C_

#include "opentitan_qspi.h"
#include "printf.h"
#include "spi_regs.h"

//#define DEBUG

static inline void writel(unsigned int val, volatile unsigned int *addr) { *addr = val; }

static inline unsigned int readl(volatile unsigned int *addr) { return *addr; }

int opentitan_qspi_init(volatile unsigned int *qspi, unsigned int clk_freq, unsigned int max_freq, unsigned int cs,
                        opentitan_qspi_t *priv) {
    if (!priv)
        return -1;

    priv->regs = qspi;
    if (!priv->regs)
        return -1;

    priv->clk_freq = clk_freq;
    if (!priv->clk_freq)
        return -1;

    // Set maximum frequency (default to 500 kHz)
    priv->max_freq = max_freq;
    if (!priv->max_freq || priv->max_freq > (priv->clk_freq / 2))
        priv->max_freq = 500000;

    priv->used_cs = cs;

#ifdef DEBUG
    printf("[opentitan_qspi] clock-frequency = %d Hz\r\n", priv->clk_freq);
    printf("[opentitan_qspi] max-frequency = %d Hz\r\n", priv->max_freq);
    printf("[opentitan_qspi] regs @ 0x%lx\r\n", (unsigned long int)priv->regs);
#endif

    return 0;
}

int opentitan_qspi_probe(opentitan_qspi_t *priv) {
    unsigned int status = 0;
    unsigned int loop_count = 0;

    // Disable all interrupts
    writel(0, priv->regs + REG_INTR_ENABLE);
    writel(0, priv->regs + REG_EVENT_ENABLE);

    // Assert SW reset of the SPI Host
    writel(OPENTITAN_QSPI_CONTROL_SW_RESET, priv->regs + REG_CONTROL);

    // Wait until the FIFOs are drained
    do {
        status = (int)readl((volatile unsigned int *)(priv->regs + REG_STATUS));
        loop_count++;

        if (loop_count >= 1000000) {
            writel(0, priv->regs + REG_CONTROL);
            return -1;
        }
    } while ((status >> 30) & 1 || (status << 16));

    // Deassert SW reset and assert enable signal => Start SPI Host
    writel((1 << 31), priv->regs + REG_CONTROL);

    // Configure the CS
    // De-select the connected peripheral by default
    writel(((priv->used_cs + 1) % SPI_HOST_PARAM_NUM_C_S), priv->regs + REG_CSID);

    // Read the byte order
    status = readl((volatile unsigned int *)(priv->regs + REG_STATUS));
    priv->byte_order = (status >> 22) & 0x1;

    return 0;
}

static int opentitan_qspi_issue_dummy(opentitan_qspi_t *priv, unsigned int bitlen, unsigned long flags) {
    unsigned char csaat = !(flags & SPI_XFER_END) && (priv->cs_state || flags & SPI_XFER_BEGIN);

    if (flags & SPI_XFER_BEGIN) {
        priv->cs_state = 1;
        writel(priv->used_cs, priv->regs + REG_CSID);
    }

    // Just setting the CS
    if (bitlen == 0) {
        if (flags & SPI_XFER_END) {
            priv->cs_state = 0;
            writel(((priv->used_cs + 1) % SPI_HOST_PARAM_NUM_C_S), priv->regs + REG_CSID);
            opentitan_qspi_issue_dummy(priv, 8, 0);
        }
        return 0;
    }

    // Wait for the SPI host to be ready
    unsigned int ready_timeout = OPENTITAN_QSPI_READY_TIMEOUT;
    unsigned int status = 0;
    do {
        status = readl((volatile unsigned int *)(priv->regs + REG_STATUS));
        ready_timeout--;
    } while (!(status >> 31) && ready_timeout > 0);

    if (ready_timeout == 0 && !(status >> 31)) {
#ifdef DEBUG
        printf("[opentitan_qspi] Error: Ready did not assert. Aborting\r\n");
#endif
        return -1;
    }

    unsigned int command = ((bitlen & 0x1FF) - 1) | ((csaat & 0x1) << 9);
    writel(command, priv->regs + REG_COMMAND);

    do {
        status = readl((volatile unsigned int *)(priv->regs + REG_STATUS));
    } while ((status >> 30) & 0x1);

    if (flags & SPI_XFER_END) {
        priv->cs_state = 0;
        writel(((priv->used_cs + 1) % SPI_HOST_PARAM_NUM_C_S), priv->regs + REG_CSID);
    }

    return 0;
}

// Expects the FIFOs to be empty and returns once the FIFOs are empty again
static int opentitan_qspi_xfer_single(opentitan_qspi_t *priv, unsigned int bitlen, const void *dout, void *din,
                                      unsigned long flags) {
#ifdef DEBUG
    //  	printf("[opentitan_qspi] Transfer: Bitlen = 0x%lx, TX: 0x%lx RX: 0x%lx, Flags: 0x%lx\r\n", bitlen, dout,
    //  din, flags);
#endif

    if (!dout && !din)
        return opentitan_qspi_issue_dummy(priv, bitlen, flags);

    if (bitlen % 8 != 0) {
#ifdef DEBUG
        printf("[opentitan_qspi] Transfers must be multiples of 8 bit long\r\n");
#endif
        return -1;
    }

    int num_bytes = bitlen / 8;
    unsigned char csaat = !(flags & SPI_XFER_END) && (priv->cs_state || flags & SPI_XFER_BEGIN);
    unsigned char dir = (din != NULL) | ((dout != NULL) << 1);

#ifdef DEBUG
    // printf("[opentitan_qspi] priv->clk_freq: %u, priv->max_freq: %u, priv->cs_state: %u, priv->byte_order: %u\r\n",
    //			priv->clk_freq, priv->max_freq, priv->cs_state, priv->byte_order);
#endif

    if (flags & SPI_XFER_BEGIN) {
        priv->cs_state = 1;
        writel(priv->used_cs, priv->regs + REG_CSID);
    }

    // Just setting the CS
    if (bitlen == 0) {
        if (flags & SPI_XFER_END) {
            priv->cs_state = 0;
            writel(((priv->used_cs + 1) % SPI_HOST_PARAM_NUM_C_S), priv->regs + REG_CSID);
            opentitan_qspi_issue_dummy(priv, 8, 0);
        }
        return 0;
    }

    unsigned int command = 0;
    unsigned int status = 0;

    if (dir >> 1) {
        int i = 0;
        // Take care of the word aligned part
        for (; i < num_bytes / 4; i++) {
            unsigned char tmp[4];

            if (!priv->byte_order) {
                tmp[3] = ((unsigned char *)dout)[4 * i];
                tmp[2] = ((unsigned char *)dout)[4 * i + 1];
                tmp[1] = ((unsigned char *)dout)[4 * i + 2];
                tmp[0] = ((unsigned char *)dout)[4 * i + 3];
            } else {
                // Read from dout according to its alignment
                // 4 byte
                if (!((long int)dout & 0x3L)) {
                    *((unsigned int *)tmp) = *((unsigned int *)(dout + 4 * i));

                    // 2 byte
                } else if (!((long int)dout & 0x1L)) {
                    *((unsigned short *)tmp) = *((unsigned short *)(dout + 4 * i));
                    *((unsigned short *)(tmp + 2)) = *((unsigned short *)(dout + 4 * i + 2));

                    // 1 byte
                } else {
                    tmp[0] = ((unsigned char *)dout)[4 * i];
                    tmp[1] = ((unsigned char *)dout)[4 * i + 1];
                    tmp[2] = ((unsigned char *)dout)[4 * i + 2];
                    tmp[3] = ((unsigned char *)dout)[4 * i + 3];
                }
            }

            writel(*((unsigned int *)tmp), priv->regs + REG_DATA);
        }

        // Less than a full word left
        if (i * 4 < num_bytes) {
            unsigned char tmp[4];

            if (!priv->byte_order) {
                // We are in here so at least one byte remains
                tmp[3] = ((unsigned char *)dout)[i * 4];
                tmp[2] = ((num_bytes - i * 4) >= 2) ? ((unsigned char *)dout)[i * 4 + 1] : 0;
                tmp[1] = ((num_bytes - i * 4) == 3) ? ((unsigned char *)dout)[i * 4 + 2] : 0;

                // Cannot need filling as it would have been taken care of by the loop then
                tmp[0] = 0;
            } else {
                // We are in here so at least one byte remains
                tmp[0] = ((unsigned char *)dout)[i * 4];
                tmp[1] = ((num_bytes - i * 4) >= 2) ? ((unsigned char *)dout)[i * 4 + 1] : 0;
                tmp[2] = ((num_bytes - i * 4) == 3) ? ((unsigned char *)dout)[i * 4 + 2] : 0;

                // Cannot need filling as it would have been taken care of by the loop then
                tmp[3] = 0;
            }

            writel(*((unsigned int *)tmp), priv->regs + REG_DATA);
        }
    }

    // Set the correct transfer mode
    command = ((num_bytes - 1) & 0x1FF) | ((csaat & 0x1) << 9) | (dir << 12);

    // Wait for the SPI host to be ready
    unsigned int ready_timeout = OPENTITAN_QSPI_READY_TIMEOUT;
    do {
        status = readl((volatile unsigned int *)(priv->regs + REG_STATUS));
        ready_timeout--;
    } while (!(status >> 31) && ready_timeout > 0);

    if (ready_timeout == 0 && !(status >> 31)) {
#ifdef DEBUG
        printf("[opentitan_qspi] Error: Ready did not assert. Aborting\r\n");
#endif
        return -1;
    }

    // Start transaction by writing to the command register
    writel(command, priv->regs + REG_COMMAND);

    // Wait for the FIFOs to be empty (full) if we had an actual data transfer
    if (priv->cs_state && dir > 0) {
        status = 0;

        // RX only or RX/TX
        if (dir == 1 || dir == 3) {
            unsigned int bytes_rcvd = 0;
            do {
                status = readl((volatile unsigned int *)(priv->regs + REG_STATUS));

                if (((status >> 8) & 0xFF)) {
                    if (bytes_rcvd < num_bytes) {
                        unsigned char *dst = (unsigned char *)din;
                        unsigned int word = readl((volatile unsigned int *)(priv->regs + REG_DATA));

                        if ((num_bytes - bytes_rcvd) >= 4) {
                            if (!priv->byte_order) {
                                dst[3] = word & 0xFF;
                                dst[2] = (word >> 8) & 0xFF;
                                dst[1] = (word >> 16) & 0xFF;
                                dst[0] = (word >> 24) & 0xFF;
                            } else {
                                // Store received data into din according to it's alignment
                                // 4 byte
                                if (!((long int)din & 0x3L)) {
                                    *((unsigned int *)din) = word;

                                    // 2 byte
                                } else if (!((long int)din & 0x1L)) {
                                    *((unsigned short *)din) = word & 0xFFFF;
                                    *((unsigned short *)(din + 2)) = (word >> 16) & 0xFFFF;

                                    // 1 byte
                                } else {
                                    dst[0] = word & 0xFF;
                                    dst[1] = (word >> 8) & 0xFF;
                                    dst[2] = (word >> 16) & 0xFF;
                                    dst[3] = (word >> 24) & 0xFF;
                                }
                            }

                            din += 4;
                            bytes_rcvd += 4;
                        } else {
                            if (!priv->byte_order) {
                                // We are in here so at least one byte remains
                                dst[0] = (word >> 24) & 0xFF;
                                bytes_rcvd++;

                                if ((num_bytes - bytes_rcvd) >= 1) {
                                    dst[1] = (word >> 16) & 0xFF;
                                    bytes_rcvd++;
                                }

                                if ((num_bytes - bytes_rcvd) == 1) {
                                    dst[2] = (word >> 8) & 0xFF;
                                    bytes_rcvd++;
                                }

                            } else {
                                // We are in here so at least one byte remains
                                dst[0] = word & 0xFF;
                                bytes_rcvd++;

                                if ((num_bytes - bytes_rcvd) >= 1) {
                                    dst[1] = (word >> 8) & 0xFF;
                                    bytes_rcvd++;
                                }

                                if ((num_bytes - bytes_rcvd) == 1) {
                                    dst[2] = (word >> 16) & 0xFF;
                                    bytes_rcvd++;
                                }
                            }
                        }

                        // Somehow we have too much data??
                    } else {
                        (void)readl((volatile unsigned int *)(priv->regs + REG_DATA));
#ifdef DEBUG
                        printf("[opentitan_qspi] Device returned more data than we requested\r\n");
#endif
                    }
                }
            } while (((status >> 8) & 0xFF) || ((status >> 30) & 0x1));

            // Wait for the last bytes of the transfer
            if (bytes_rcvd < num_bytes) {
                unsigned int read_timeout = OPENTITAN_QSPI_READ_TIMEOUT;
                do {
                    status = readl((volatile unsigned int *)(priv->regs + REG_STATUS));
                    read_timeout--;
                } while (!((status >> 8) & 0xFF) && read_timeout > 0);

                if (read_timeout == 0 && !((status >> 8) & 0xFF)) {
#ifdef DEBUG
                    printf("[opentitan_qspi] Error: RX queue did not notify us about the last bytes\r\n");
#endif
                    return -1;
                }

                unsigned int word = readl((volatile unsigned int *)(priv->regs + REG_DATA));
                unsigned char *dst = (unsigned char *)din;

#ifdef DEBUG
                printf("[opentitan_qspi] Leftover read data: %d\r\n", num_bytes - bytes_rcvd);
                printf("[opentitan_qspi] Word = 0x%x\r\n", word);
#endif

                if (!priv->byte_order) {
                    // We are in here so at least one byte remains
                    dst[0] = (word >> 24) & 0xFF;
                    bytes_rcvd++;

                    if ((num_bytes - bytes_rcvd) >= 1) {
                        dst[1] = (word >> 16) & 0xFF;
                        bytes_rcvd++;
                    }

                    if ((num_bytes - bytes_rcvd) >= 1) {
                        dst[2] = (word >> 8) & 0xFF;
                        bytes_rcvd++;
                    }

                    if ((num_bytes - bytes_rcvd) == 1) {
                        dst[3] = word & 0xFF;
                        bytes_rcvd++;
                    }

                } else {
                    // We are in here so at least one byte remains
                    dst[0] = word & 0xFF;
                    bytes_rcvd++;

                    if ((num_bytes - bytes_rcvd) >= 1) {
                        dst[1] = (word >> 8) & 0xFF;
                        bytes_rcvd++;
                    }

                    if ((num_bytes - bytes_rcvd) >= 1) {
                        dst[2] = (word >> 16) & 0xFF;
                        bytes_rcvd++;
                    }

                    if ((num_bytes - bytes_rcvd) == 1) {
                        dst[3] = (word >> 24) & 0xFF;
                        bytes_rcvd++;
                    }
                }
            }

            // TX Only
        } else if (dir == 2) {
            do {
                status = readl((volatile unsigned int *)(priv->regs + REG_STATUS));
            } while ((status >> 30) & 0x1);

            // What mode is this??
        } else {
#ifdef DEBUG
            printf("[opentitan_qspi] This direction is unknown: %d\r\n", dir);
#endif
            return -1;
        }
    }

    if (flags & SPI_XFER_END) {
        priv->cs_state = 0;
        writel(((priv->used_cs + 1) % SPI_HOST_PARAM_NUM_C_S), priv->regs + REG_CSID);
    }

    return 0;
}

int opentitan_qspi_xfer(opentitan_qspi_t *priv, unsigned int bitlen, const void *dout, void *din, unsigned long flags) {
    // Yay a single transaction
    if (bitlen <= OPENTITAN_QSPI_FIFO_DEPTH * 8) {
        return opentitan_qspi_xfer_single(priv, bitlen, dout, din, flags);

        // Aww multiple transactions
    } else {
        unsigned long first_flags = flags & SPI_XFER_BEGIN;
        unsigned long last_flags = flags & SPI_XFER_END;
        unsigned int num_txns = (bitlen + OPENTITAN_QSPI_FIFO_DEPTH * 8 - 1) / (OPENTITAN_QSPI_FIFO_DEPTH * 8);

        for (unsigned int i = 0; i < num_txns; i++) {
            unsigned long flags = (i == 0) ? first_flags : (i == num_txns - 1) ? last_flags : 0;
            unsigned int ret = 0;
            unsigned int len = ((bitlen - i * OPENTITAN_QSPI_FIFO_DEPTH * 8) < OPENTITAN_QSPI_FIFO_DEPTH * 8)
                                   ? (bitlen - i * OPENTITAN_QSPI_FIFO_DEPTH * 8)
                                   : OPENTITAN_QSPI_FIFO_DEPTH * 8;
            void const *out = NULL;
            void *in = NULL;

            if (dout)
                out = (void *)(dout + i * OPENTITAN_QSPI_FIFO_DEPTH);

            if (din)
                in = (void *)(din + i * OPENTITAN_QSPI_FIFO_DEPTH);

            ret = opentitan_qspi_xfer_single(priv, len, out, in, flags);

            if (ret)
                return ret;
        }

        return 0;
    }
}

int opentitan_qspi_set_speed(opentitan_qspi_t *priv, unsigned int speed) {
    unsigned long int clkdiv = 0;
    unsigned int configopts = 0;

    if (speed > priv->max_freq) {
#ifdef DEBUG
        printf("[opentitan_qspi] Requested frequency is higher than maximum possible frequency!\r\n");
        printf("[opentitan_qspi] Req: %d, Max: %d\r\n", speed, priv->max_freq);
#endif
        speed = priv->max_freq;
    }

#ifdef DEBUG
    printf("[opentitan_qspi] Setting SPI frequency to %d Hz\r\n", speed);
#endif

    // SPI_CLK = SYS_CLK/(2*(clkdiv+1))
    // clkdiv = SYS_CLK/(2*SPI_CLK) - 1

    clkdiv = priv->clk_freq + 2 * speed - 1L;
    clkdiv = clkdiv / (2 * speed) - 1L;

    if (clkdiv != (clkdiv & (~(-1 << 16)))) {
#ifdef DEBUG
        printf("[opentitan_qspi] Calculated clock divider overflows the hardware register! Using maximum value\r\n");
#endif
        clkdiv = ~(-1 << 16);
    }

    configopts = (unsigned int)readl((volatile unsigned int *)(priv->regs + REG_CONFIGOPTS_0 + priv->used_cs));
    configopts = (configopts & (-1 << 16)) | (clkdiv & ~(-1 << 16));
    writel(configopts, priv->regs + REG_CONFIGOPTS_0 + priv->used_cs);

    // This is dirty... we are wasting a whole chip select just to be able to control the chipselect
    // independently of the rest of the SPI bus
    writel(configopts, priv->regs + REG_CONFIGOPTS_0 + ((priv->used_cs + 1) % SPI_HOST_PARAM_NUM_C_S));

    return 0;
}

int opentitan_qspi_set_mode(opentitan_qspi_t *priv, unsigned int mode) {
    unsigned int configopts = 0;

    configopts = (unsigned int)readl((volatile unsigned int *)(priv->regs + REG_CONFIGOPTS_0 + priv->used_cs));
    configopts = (configopts & 0xFFFF) | (0xFFF << 16) | ((mode & 0x3) << 30);
    writel(configopts, priv->regs + REG_CONFIGOPTS_0 + priv->used_cs);
    writel(configopts, priv->regs + REG_CONFIGOPTS_0 + ((priv->used_cs + 1) % SPI_HOST_PARAM_NUM_C_S));

    return 0;
}

#endif // OPENTITAN_QSPI_C_
