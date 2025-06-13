/*	$OpenBSD: sdhcvar.h,v 1.17 2023/04/19 02:01:02 dlg Exp $	*/

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

#ifndef _SDHCVAR_H_
#define _SDHCVAR_H_

#include "types.h"

struct sdhc_host {
	u_int mmio;

	u_int16_t version;		/* specification version */
	u_int clkbase;			/* base clock frequency in KHz */
	int maxblklen;			/* maximum block length */
	int flags;			/* flags for this host */
#define SDHC_F_NOPWR0		(1 << 0)
#define SDHC_F_NONREMOVABLE	(1 << 1)
#define SDHC_F_NO_HS_BIT	(1 << 3)
	u_int16_t intr_status;		/* soft interrupt status */
	u_int16_t intr_error_status;	/* soft error status */

	uint16_t block_size;
	uint16_t block_count;
	uint16_t transfer_mode;
};

int	sdhc_init(struct sdhc_host *hp, u_int mmio, uint64_t capmask, uint64_t capset);

/* flag values */

#endif

struct sdmmc_command;

int	sdhc_host_reset(struct sdhc_host*);
int	sdhc_host_maxblklen(struct sdhc_host*);
int	sdhc_card_detect(struct sdhc_host*);
int	sdhc_bus_clock(struct sdhc_host*, int, int);
int	sdhc_bus_width(struct sdhc_host*, int);
void	sdhc_card_intr_mask(struct sdhc_host*, int);
void	sdhc_card_intr_ack(struct sdhc_host*);
int	sdhc_signal_voltage(struct sdhc_host*, int);
void	sdhc_exec_command(struct sdhc_host*, struct sdmmc_command *);
int	sdhc_start_command(struct sdhc_host *, struct sdmmc_command *);
int	sdhc_wait_state(struct sdhc_host *, u_int32_t, u_int32_t);
int	sdhc_soft_reset(struct sdhc_host *, int);
int	sdhc_wait_intr(struct sdhc_host *, int, int);
void	sdhc_transfer_data(struct sdhc_host *, struct sdmmc_command *);
void	sdhc_read_data(struct sdhc_host *, u_char *, int);
void	sdhc_write_data(struct sdhc_host *, u_char *, int);
