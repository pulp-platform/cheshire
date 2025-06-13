/*	$OpenBSD: sdmmc.c,v 1.62 2024/08/18 15:03:01 deraadt Exp $	*/

/*
 * Copyright (c) 2006 Uwe Stuehler <uwe@openbsd.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/*
 * Host controller independent SD/MMC bus driver based on information
 * from SanDisk SD Card Product Manual Revision 2.2 (SanDisk), SDIO
 * Simple Specification Version 1.0 (SDIO) and the Linux "mmc" driver.
 */

#include "dif/sdmmcchip.h"
#include "dif/sdmmcreg.h"
#include "dif/sdmmcvar.h"

#include "dif/clint.h"

int	sdmmc_enable(struct sdmmc_softc *);
void	sdmmc_disable(struct sdmmc_softc *);
int	sdmmc_scan(struct sdmmc_softc *);
void sdmmc_card_attach(struct sdmmc_softc *sc);
void sdmmc_card_detach(struct sdmmc_softc *sc, int flags);


#ifdef SDMMC_DEBUG
int sdmmcdebug = 2;
void sdmmc_dump_command(struct sdmmc_softc *, struct sdmmc_command *);
#define DPRINTF(n,s)	do { if ((n) <= sdmmcdebug) printf s; } while (0)
#else
#define DPRINTF(n,s)	do {} while (0)
#endif


void
sdmmc_init(struct sdmmc_softc *sc, struct sdhc_host *hp, uint8_t* scratch_buffer)
{
	DFUNC(sdmmc_init);

	sc->sch = hp;
	sc->sc_flags = SMF_MEM_MODE;
	sc->sc_caps = SMC_CAPS_4BIT_MODE;
	sc->scratch_buffer = scratch_buffer;

	if (ISSET(hp->flags, SDHC_F_NONREMOVABLE))
		sc->sc_caps |= SMC_CAPS_NONREMOVABLE;
	
	SET(sc->sc_flags, SMF_CONFIG_PENDING);
	sdmmc_discover_cards(sc);

	sc->scratch_buffer = NULL;
}

int
sdmmc_detach(struct device *self, int flags)
{
	struct sdmmc_softc *sc = (struct sdmmc_softc *)self;
	sdmmc_card_detach(sc, DETACH_FORCE);

	return 0;
}

void
sdmmc_discover_cards(struct sdmmc_softc *sc)
{
	DFUNC(sdmmc_discover_cards);

	if (sdhc_card_detect(sc->sch)) {
		if (!ISSET(sc->sc_flags, SMF_CARD_PRESENT)) {
			SET(sc->sc_flags, SMF_CARD_PRESENT);
			sdmmc_card_attach(sc);
		}
	} else {
		if (ISSET(sc->sc_flags, SMF_CARD_PRESENT)) {
			CLR(sc->sc_flags, SMF_CARD_PRESENT);
			// rw_enter_write(&sc->sc_lock);
			sdmmc_card_detach(sc, DETACH_FORCE);
			// rw_exit(&sc->sc_lock);
		}
	}

	if (ISSET(sc->sc_flags, SMF_CONFIG_PENDING)) {
		CLR(sc->sc_flags, SMF_CONFIG_PENDING);
		// config_pending_decr();
	}
}

/*
 * Called from process context when a card is present.
 */
void
sdmmc_card_attach(struct sdmmc_softc *sc)
{
	DFUNC(sdmmc_card_attach);

	// rw_enter_write(&sc->sc_lock);
	CLR(sc->sc_flags, SMF_CARD_ATTACHED);

	/*
	 * Power up the card (or card stack).
	 */
	if (sdmmc_enable(sc) != 0) {
		DPRINTF(0, ("%s: can't enable card\n", DEVNAME(sc)));
		goto err;
	}

	/*
	 * Scan for I/O functions and memory cards on the bus,
	 * allocating a sdmmc_function structure for each.
	 */
	sdmmc_mem_scan(sc);

	/*
	 * Initialize the I/O functions and memory cards.
	 */
	if (sdmmc_mem_init(sc, &sc->sc_card) != 0) {
		DPRINTF(0, ("%s: mem init failed\n", DEVNAME(sc)));
		goto err;
	}

	SET(sc->sc_flags, SMF_CARD_ATTACHED);
	// rw_exit(&sc->sc_lock);
	return;
err:
	sdmmc_card_detach(sc, DETACH_FORCE);
	// rw_exit(&sc->sc_lock);
}

/*
 * Called from process context with DETACH_* flags from <sys/device.h>
 * when cards are gone.
 */
void
sdmmc_card_detach(struct sdmmc_softc *sc, int flags)
{
	struct sdmmc_function *sf, *sfnext;

	// rw_assert_wrlock(&sc->sc_lock);

	DPRINTF(1,("%s: detach card\n", DEVNAME(sc)));

	if (ISSET(sc->sc_flags, SMF_CARD_ATTACHED)) {
		CLR(sc->sc_flags, SMF_CARD_ATTACHED);
	}

	sdmmc_disable(sc);
	sc->sc_card.rca = 0;
}

int
sdmmc_enable(struct sdmmc_softc *sc)
{
	DFUNC(sdmmc_enable);

	u_int32_t host_ocr;
	int error;

	/*
	 * Select the minimum clock frequency.
	 */
	error = sdhc_bus_clock(sc->sch,
	    SDMMC_SDCLK_400KHZ, SDMMC_TIMING_LEGACY);
	if (error != 0) {
		DPRINTF(0, ("%s: can't supply clock\n", DEVNAME(sc)));
		goto err;
	}

	/* XXX wait for card to power up */
#ifndef SDMMC_DEBUG
	// TODO
	sdmmc_delay(250000);
#endif

	/* Initialize SD I/O card function(s). */
	// if ((error = sdmmc_io_enable(sc)) != 0)
	// 	goto err;

	/* Initialize SD/MMC memory card(s). */
	if (ISSET(sc->sc_flags, SMF_MEM_MODE) &&
	    (error = sdmmc_mem_enable(sc)) != 0)
		goto err;

 err:
	if (error != 0)
		sdmmc_disable(sc);

	return error;
}

void
sdmmc_disable(struct sdmmc_softc *sc)
{
	DFUNC(sdmmc_disable);

	/* XXX complete commands if card is still present. */

	// rw_assert_wrlock(&sc->sc_lock);

	/* Make sure no card is still selected. */
	(void)sdmmc_select_card(sc, NULL);

	/* Turn off bus power and clock. */
	(void)sdhc_bus_clock(sc->sch,
	    SDMMC_SDCLK_OFF, SDMMC_TIMING_LEGACY);
}

struct sdmmc_function*
sdmmc_function_alloc(struct sdmmc_softc *sc)
{
	DFUNC(sdmmc_function_alloc);

	struct sdmmc_function* sf = &sc->sc_card;
	bzero(sf, sizeof(*sf));

	return sf;
}

/*
 * Scan for I/O functions and memory cards on the bus, allocating a
 * sdmmc_function structure for each.
 */
int
sdmmc_scan(struct sdmmc_softc *sc)
{
	DFUNC(sdmmc_scan);
	// rw_assert_wrlock(&sc->sc_lock);

	/* Scan for memory cards on the bus. */
	if (ISSET(sc->sc_flags, SMF_MEM_MODE))

	return 0;
}

void
sdmmc_delay(u_int usecs)
{
	clint_spin_ticks(usecs * 32);
}

int
sdmmc_app_command(struct sdmmc_softc *sc, struct sdmmc_command *cmd)
{
	DFUNC(sdmmc_app_command);

	struct sdmmc_command acmd;
	int error;

	// rw_assert_wrlock(&sc->sc_lock);

	bzero(&acmd, sizeof acmd);
	acmd.c_opcode = MMC_APP_CMD;
	acmd.c_arg = sc->sc_card.rca << 16;
	acmd.c_flags = SCF_CMD_AC | SCF_RSP_R1;

	error = sdmmc_mmc_command(sc, &acmd);
	if (error != 0) {
		return error;
	}

	if (!ISSET(MMC_R1(acmd.c_resp), MMC_R1_APP_CMD)) {
		/* Card does not support application commands. */
		DPRINTF(1,("%s: Card does not support ACMD %x\n", DEVNAME(sc), acmd.c_resp[0]));
		return ENODEV;
	}

	error = sdmmc_mmc_command(sc, cmd);
	return error;
}

/*
 * Execute MMC command and data transfers.  All interactions with the
 * host controller to complete the command happen in the context of
 * the current process.
 */
int
sdmmc_mmc_command(struct sdmmc_softc *sc, struct sdmmc_command *cmd)
{
	DFUNC(sdmmc_mmc_command);

	sdhc_exec_command(sc->sch, cmd);

#ifdef SDMMC_DEBUG
	sdmmc_dump_command(sc, cmd);
#endif

	return cmd->c_error;
}

/*
 * Send the "GO IDLE STATE" command.
 */
void
sdmmc_go_idle_state(struct sdmmc_softc *sc)
{
	DFUNC(sdmmc_go_idle_state);

	struct sdmmc_command cmd;

	// rw_assert_wrlock(&sc->sc_lock);

	bzero(&cmd, sizeof cmd);
	cmd.c_opcode = MMC_GO_IDLE_STATE;
	cmd.c_flags = SCF_CMD_BC | SCF_RSP_R0;

	(void)sdmmc_mmc_command(sc, &cmd);
}

/*
 * Send the "SEND_IF_COND" command, to check operating condition
 */
int
sdmmc_send_if_cond(struct sdmmc_softc *sc, uint32_t card_ocr)
{
	DFUNC(sdmmc_send_if_cond);

	struct sdmmc_command cmd;
	uint8_t pat = 0x23;	/* any pattern will do here */
	uint8_t res;

	// rw_assert_wrlock(&sc->sc_lock);

	bzero(&cmd, sizeof cmd);

	cmd.c_opcode = SD_SEND_IF_COND;
	cmd.c_arg = ((card_ocr & SD_OCR_VOL_MASK) != 0) << 8 | pat;
	cmd.c_flags = SCF_CMD_BCR | SCF_RSP_R7;

	if (sdmmc_mmc_command(sc, &cmd) != 0)
		return 1;

	res = cmd.c_resp[0];
	if (res != pat)
		return 1;
	else
		return 0;
}

/*
 * Retrieve (SD) or set (MMC) the relative card address (RCA).
 */
int
sdmmc_set_relative_addr(struct sdmmc_softc *sc,
    struct sdmmc_function *sf)
{
	DFUNC(sdmmc_set_relative_addr);

	struct sdmmc_command cmd;

	// rw_assert_wrlock(&sc->sc_lock);

	bzero(&cmd, sizeof cmd);

	if (ISSET(sc->sc_flags, SMF_SD_MODE)) {
		cmd.c_opcode = SD_SEND_RELATIVE_ADDR;
		cmd.c_flags = SCF_CMD_BCR | SCF_RSP_R6;
	} else {
		cmd.c_opcode = MMC_SET_RELATIVE_ADDR;
		cmd.c_arg = MMC_ARG_RCA(sf->rca);
		cmd.c_flags = SCF_CMD_AC | SCF_RSP_R1;
	}

	if (sdmmc_mmc_command(sc, &cmd) != 0)
		return 1;

	if (ISSET(sc->sc_flags, SMF_SD_MODE))
		sf->rca = SD_R6_RCA(cmd.c_resp);
	return 0;
}

int
sdmmc_select_card(struct sdmmc_softc *sc, struct sdmmc_function *sf)
{
	DFUNC(sdmmc_select_card);

	struct sdmmc_command cmd;
	int error;

	bzero(&cmd, sizeof cmd);
	cmd.c_opcode = MMC_SELECT_CARD;
	cmd.c_arg = sf == NULL ? 0 : MMC_ARG_RCA(sf->rca);
	cmd.c_flags = SCF_CMD_AC | (sf == NULL ? SCF_RSP_R0 : SCF_RSP_R1);

	return sdmmc_mmc_command(sc, &cmd);
}

#ifdef SDMMC_DEBUG
void
sdmmc_dump_command(struct sdmmc_softc *sc, struct sdmmc_command *cmd)
{
	DFUNC(sdmmc_dump_command);

	int i;

	// rw_assert_wrlock(&sc->sc_lock);

	DPRINTF(1,("%s: cmd %u arg=%#x data=%p dlen=%d flags=%#x "
	    "(error %d)\n", DEVNAME(sc), cmd->c_opcode,
	    cmd->c_arg, cmd->c_data, cmd->c_datalen, cmd->c_flags,
	    cmd->c_error));

	if (cmd->c_error || sdmmcdebug < 1)
		return;

	printf("%s: resp=", DEVNAME(sc));
	if (ISSET(cmd->c_flags, SCF_RSP_136))
		for (i = 0; i < sizeof cmd->c_resp; i++)
			printf("%02x ", ((u_char *)cmd->c_resp)[i]);
	else if (ISSET(cmd->c_flags, SCF_RSP_PRESENT))
		for (i = 0; i < 4; i++)
			printf("%02x ", ((u_char *)cmd->c_resp)[i]);
	printf("\n");
}
#endif
