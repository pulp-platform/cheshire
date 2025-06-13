/*	$OpenBSD: sdmmcchip.h,v 1.15 2023/04/19 02:01:02 dlg Exp $	*/

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

#ifndef _SDMMC_CHIP_H_
#define _SDMMC_CHIP_H_

#include "dif/types.h"
#include "dif/sdhcvar.h"

struct sdmmc_command;

/* clock frequencies for sdmmc_chip_bus_clock() */
#define SDMMC_SDCLK_OFF		0
#define SDMMC_SDCLK_400KHZ	400
#define SDMMC_SDCLK_25MHZ	25000
#define SDMMC_SDCLK_50MHZ	50000

/* voltage levels for sdmmc_chip_signal_voltage() */
#define SDMMC_SIGNAL_VOLTAGE_330	0
#define SDMMC_SIGNAL_VOLTAGE_180	1

#define SDMMC_TIMING_LEGACY	0
#define SDMMC_TIMING_HIGHSPEED	1
#define SDMMC_TIMING_UHS_SDR50	2
#define SDMMC_TIMING_UHS_SDR104	3
#define SDMMC_TIMING_MMC_DDR52	4
#define SDMMC_TIMING_MMC_HS200	5

struct sdmmcbus_attach_args {
	const char *saa_busname;
	struct sdhc_host* sch;

	int	flags;
	int	caps;
	long	max_seg;
	long	max_xfer;
};

struct device;

void	sdmmc_delay(u_int);
#endif
