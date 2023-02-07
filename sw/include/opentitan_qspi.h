// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#pragma once

#define MIN(a, b) ((a <= b) ? a : b)

// Bit 30 in Control: SW Reset
#define OPENTITAN_QSPI_CONTROL_SW_RESET (1 << 30)

// Probably an underestimate by one
#define OPENTITAN_QSPI_TXFIFO_DEPTH 256
#define OPENTITAN_QSPI_RXFIFO_DEPTH 256
#define OPENTITAN_QSPI_FIFO_DEPTH MIN(OPENTITAN_QSPI_TXFIFO_DEPTH, OPENTITAN_QSPI_RXFIFO_DEPTH)

#define OPENTITAN_QSPI_READY_TIMEOUT 10000
#define OPENTITAN_QSPI_READ_TIMEOUT 10000

#define SPI_XFER_BEGIN 1
#define SPI_XFER_END 2

/* opentitan qspi register set */
enum opentitan_qspi_regs {
    REG_INTR_STATE,   /* Interrupt State Register */
    REG_INTR_ENABLE,  /* Interrupt Enable Register */
    REG_INTR_TEST,    /* Interrupt Test Register */
    REG_ALERT_TEST,   /* Alert Test Register */
    REG_CONTROL,      /* Control Register */
    REG_STATUS,       /* Status Register */
    REG_CONFIGOPTS_0, /* Configuration Options Register 1 */
    REG_CONFIGOPTS_1, /* Configuration Options Register 2 */
    REG_CSID,         /* Chip-Select ID */
    REG_COMMAND,      /* Command Register */
    REG_DATA,         /* SPI Data Window*/
    REG_ERROR_ENABLE, /* Controls which classes of error raise an interrupt */
    REG_ERROR_STATUS, /* Indicates that any errors have occured */
    REG_EVENT_ENABLE, /* Controls which classes of SPI events raise an interrupt */
};

/* opentitan qspi priv */
typedef struct opentitan_qspi_priv {
    volatile unsigned int *regs;
    unsigned int clk_freq; /* Peripheral clock frequency */
    unsigned int max_freq; /* Max supported SPI frequency */
    unsigned int used_cs;
    unsigned int cs_state;    /* 0 = CS currently not asserted, 1 = CS currently asserted */
    unsigned char byte_order; /* 1 = LSB shifted in/out first, 0 = MSB shifted in/out first */
} opentitan_qspi_t;

int opentitan_qspi_init(volatile unsigned int *qspi, unsigned int clk_freq, unsigned int max_freq, unsigned int cs,
                        opentitan_qspi_t *priv);

int opentitan_qspi_probe(opentitan_qspi_t *priv);

int opentitan_qspi_xfer(opentitan_qspi_t *priv, unsigned int bitlen, const void *dout, void *din, unsigned long flags);

int opentitan_qspi_set_speed(opentitan_qspi_t *priv, unsigned int speed);

int opentitan_qspi_set_mode(opentitan_qspi_t *priv, unsigned int mode);
