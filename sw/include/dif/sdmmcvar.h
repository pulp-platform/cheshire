/*	$OpenBSD: sdmmcvar.h,v 1.34 2020/08/14 14:49:04 kettenis Exp $	*/

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

#ifndef _SDMMCVAR_H_
#define _SDMMCVAR_H_

#include "sdmmcchip.h"
#include "sdmmcreg.h"

struct sdmmc_csd {
	int	csdver;		/* CSD structure format */
	int	mmcver;		/* MMC version (for CID format) */
	int	capacity;	/* total number of sectors */
	int	sector_size;	/* sector size in bytes */
	int	read_bl_len;	/* block length for reads */
	int	tran_speed;	/* transfer speed (kbit/s) */
	int	ccc;		/* Card Command Class for SD */
	/* ... */
};

struct sdmmc_scr {
	int	sd_spec;
	int	bus_width;
};

typedef u_int32_t sdmmc_response[4];

struct sdmmc_softc;

struct sdmmc_command {
	u_int16_t	 c_opcode;	/* SD or MMC command index */
	u_int32_t	 c_arg;		/* SD/MMC command argument */
	sdmmc_response	 	c_resp;	/* response buffer */
	void		*c_data;	/* buffer to send or read into */
	int		 c_datalen;	/* length of data buffer */
	int		 c_blklen;	/* block length */
	int		 c_flags;	/* see below */
#define SCF_ITSDONE	 0x0001		/* command is complete */
#define SCF_CMD(flags)	 ((flags) & 0x00f0)
#define SCF_CMD_AC	 0x0000
#define SCF_CMD_ADTC	 0x0010
#define SCF_CMD_BC	 0x0020
#define SCF_CMD_BCR	 0x0030
#define SCF_CMD_READ	 0x0040		/* read command (data expected) */
#define SCF_RSP_BSY	 0x0100
#define SCF_RSP_136	 0x0200
#define SCF_RSP_CRC	 0x0400
#define SCF_RSP_IDX	 0x0800
#define SCF_RSP_PRESENT	 0x1000
/* response types */
#define SCF_RSP_R0	 0 /* none */
#define SCF_RSP_R1	 (SCF_RSP_PRESENT|SCF_RSP_CRC|SCF_RSP_IDX)
#define SCF_RSP_R1B	 (SCF_RSP_PRESENT|SCF_RSP_CRC|SCF_RSP_IDX|SCF_RSP_BSY)
#define SCF_RSP_R2	 (SCF_RSP_PRESENT|SCF_RSP_CRC|SCF_RSP_136)
#define SCF_RSP_R3	 (SCF_RSP_PRESENT)
#define SCF_RSP_R4	 (SCF_RSP_PRESENT)
#define SCF_RSP_R5	 (SCF_RSP_PRESENT|SCF_RSP_CRC|SCF_RSP_IDX)
#define SCF_RSP_R5B	 (SCF_RSP_PRESENT|SCF_RSP_CRC|SCF_RSP_IDX|SCF_RSP_BSY)
#define SCF_RSP_R6	 (SCF_RSP_PRESENT|SCF_RSP_CRC|SCF_RSP_IDX)
#define SCF_RSP_R7	 (SCF_RSP_PRESENT|SCF_RSP_CRC|SCF_RSP_IDX)
	int		 c_error;	/* errno value on completion */
};

/*
 * Structure describing either an SD card I/O function or a SD/MMC
 * memory card from a "stack of cards" that responded to CMD2.  For a
 * combo card with one I/O function and one memory card, there will be
 * two of these structures allocated.  Each card slot has such a list
 * of sdmmc_function structures.
 */
struct sdmmc_function {
	/* common members */
	struct sdmmc_softc *sc;		/* card slot softc */
	u_int16_t rca;			/* relative card address */
	int flags;
#define SFF_SDHC		0x0002	/* SD High Capacity card */
	unsigned int cur_blklen;	/* current block length */
	/* SD/MMC memory card members */
	struct sdmmc_csd csd;		/* decoded CSD value */
	struct sdmmc_scr scr;		/* decoded SCR value */
};

/*
 * Structure describing a single SD/MMC/SDIO card slot.
 */
struct sdmmc_softc {
#define DEVNAME(sc)	("SDHC")
	struct sdhc_host* sch;	/* host controller chipset handle */

#define SDMMC_MAXNSEGS	((MAXPHYS / PAGE_SIZE) + 1)

	int sc_flags;
#define SMF_SD_MODE		0x0001	/* host in SD mode (MMC otherwise) */
#define SMF_IO_MODE		0x0002	/* host in I/O mode (SD mode only) */
#define SMF_MEM_MODE		0x0004	/* host in memory mode (SD or MMC) */
#define SMF_UHS_MODE		0x0010	/* host in UHS mode */
#define SMF_CARD_PRESENT	0x0020	/* card presence noticed */
#define SMF_CARD_ATTACHED	0x0040	/* card driver(s) attached */
#define SMF_STOP_AFTER_MULTIPLE	0x0080	/* send a stop after a multiple cmd */
#define SMF_CONFIG_PENDING	0x0100	/* config_pending_incr() called */

	uint32_t sc_caps;		/* host capability */
#define SMC_CAPS_AUTO_STOP	0x0001	/* send CMD12 automagically by host */
#define SMC_CAPS_4BIT_MODE	0x0002	/* 4-bits data bus width */
#define SMC_CAPS_DMA		0x0004	/* DMA transfer */
#define SMC_CAPS_SPI_MODE	0x0008	/* SPI mode */
#define SMC_CAPS_POLL_CARD_DET	0x0010	/* Polling card detect */
#define SMC_CAPS_SINGLE_ONLY	0x0020	/* only single read/write */
#define SMC_CAPS_8BIT_MODE	0x0040	/* 8-bits data bus width */
#define SMC_CAPS_MULTI_SEG_DMA	0x0080	/* multiple segment DMA transfer */
#define SMC_CAPS_SD_HIGHSPEED	0x0100	/* SD high-speed timing */
#define SMC_CAPS_MMC_HIGHSPEED	0x0200	/* MMC high-speed timing */
#define SMC_CAPS_UHS_SDR50	0x0400	/* UHS SDR50 timing */
#define SMC_CAPS_UHS_SDR104	0x0800	/* UHS SDR104 timing */
#define SMC_CAPS_UHS_DDR50	0x1000	/* UHS DDR50 timing */
#define SMC_CAPS_UHS_MASK	0x1c00
#define SMC_CAPS_MMC_DDR52	0x2000  /* eMMC DDR52 timing */
#define SMC_CAPS_MMC_HS200	0x4000	/* eMMC HS200 timing */
#define SMC_CAPS_MMC_HS400	0x8000	/* eMMC HS400 timing */
#define SMC_CAPS_NONREMOVABLE	0x10000	/* non-removable devices */

	struct sdmmc_function sc_card;	/* selected card */

	uint8_t* scratch_buffer; /* Buffer that is atleast 512 Bytes to use for temporary storage, only used during initialization */
};

#define	SDMMC_ASSERT_LOCKED(sc) \
	rw_assert_wrlock(&(sc)->sc_lock)


void sdmmc_init(struct sdmmc_softc *, struct sdhc_host *, uint8_t*);
struct	sdmmc_function *sdmmc_function_alloc(struct sdmmc_softc *);
int	sdmmc_mmc_command(struct sdmmc_softc *, struct sdmmc_command *);
int	sdmmc_app_command(struct sdmmc_softc *, struct sdmmc_command *);
void	sdmmc_go_idle_state(struct sdmmc_softc *);
int	sdmmc_set_relative_addr(struct sdmmc_softc *,
	    struct sdmmc_function *);
int	sdmmc_send_if_cond(struct sdmmc_softc *, uint32_t);

void sdmmc_discover_cards(struct sdmmc_softc *);

int	sdmmc_mem_enable(struct sdmmc_softc *);
int	sdmmc_mem_scan(struct sdmmc_softc *);
int	sdmmc_mem_init(struct sdmmc_softc *, struct sdmmc_function *);
int	sdmmc_mem_read_block(struct sdmmc_function *, int, u_char *, size_t);
int	sdmmc_mem_write_block(struct sdmmc_function *, int, u_char *, size_t);
int	sdmmc_mem_set_blocklen(struct sdmmc_softc *, struct sdmmc_function *);
int sdmmc_select_card(struct sdmmc_softc *, struct sdmmc_function *);

int	sdmmc_mem_send_scr(struct sdmmc_softc *, uint32_t *);
int	sdmmc_mem_decode_scr(struct sdmmc_softc *, uint32_t *,
	    struct sdmmc_function *);

#endif
