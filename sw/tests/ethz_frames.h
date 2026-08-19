#pragma once

#include <stdint.h>

#define ETHZ_FRAME_WIDTH   32
#define ETHZ_FRAME_HEIGHT  16

#define ETHZ_BLACK 0x0000
#define ETHZ_WHITE 0xFFFF

/*
 * ETHZ animation
 *
 * Resolution: 32 x 16
 * Format:     RGB565
 *
 * The text "ETHZ" scrolls fully across the screen, from
 * entering off-screen on the right to exiting off-screen
 * on the left.
 *
 * Every array contains exactly 32 * 16 RGB565 pixels.
 * Unspecified pixels are initialized to 0x0000 (black).
 *
 * All frames are aligned to 8 bytes so they can safely be read
 * through uint64_t accesses.
 */


// -----------------------------------------------------------------------------
// Frame 0
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_0[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [191] = ETHZ_WHITE,
    [223] = ETHZ_WHITE,
    [255] = ETHZ_WHITE,
    [287] = ETHZ_WHITE,
    [319] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 1
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_1[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [187] = ETHZ_WHITE,
    [188] = ETHZ_WHITE,
    [189] = ETHZ_WHITE,
    [191] = ETHZ_WHITE,
    [219] = ETHZ_WHITE,
    [251] = ETHZ_WHITE,
    [252] = ETHZ_WHITE,
    [283] = ETHZ_WHITE,
    [315] = ETHZ_WHITE,
    [316] = ETHZ_WHITE,
    [317] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 2
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_2[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [183] = ETHZ_WHITE,
    [184] = ETHZ_WHITE,
    [185] = ETHZ_WHITE,
    [187] = ETHZ_WHITE,
    [188] = ETHZ_WHITE,
    [189] = ETHZ_WHITE,
    [191] = ETHZ_WHITE,
    [215] = ETHZ_WHITE,
    [220] = ETHZ_WHITE,
    [223] = ETHZ_WHITE,
    [247] = ETHZ_WHITE,
    [248] = ETHZ_WHITE,
    [252] = ETHZ_WHITE,
    [255] = ETHZ_WHITE,
    [279] = ETHZ_WHITE,
    [284] = ETHZ_WHITE,
    [287] = ETHZ_WHITE,
    [311] = ETHZ_WHITE,
    [312] = ETHZ_WHITE,
    [313] = ETHZ_WHITE,
    [316] = ETHZ_WHITE,
    [319] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 3
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_3[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [178] = ETHZ_WHITE,
    [179] = ETHZ_WHITE,
    [180] = ETHZ_WHITE,
    [182] = ETHZ_WHITE,
    [183] = ETHZ_WHITE,
    [184] = ETHZ_WHITE,
    [186] = ETHZ_WHITE,
    [188] = ETHZ_WHITE,
    [190] = ETHZ_WHITE,
    [191] = ETHZ_WHITE,
    [210] = ETHZ_WHITE,
    [215] = ETHZ_WHITE,
    [218] = ETHZ_WHITE,
    [220] = ETHZ_WHITE,
    [242] = ETHZ_WHITE,
    [243] = ETHZ_WHITE,
    [247] = ETHZ_WHITE,
    [250] = ETHZ_WHITE,
    [251] = ETHZ_WHITE,
    [252] = ETHZ_WHITE,
    [255] = ETHZ_WHITE,
    [274] = ETHZ_WHITE,
    [279] = ETHZ_WHITE,
    [282] = ETHZ_WHITE,
    [284] = ETHZ_WHITE,
    [286] = ETHZ_WHITE,
    [306] = ETHZ_WHITE,
    [307] = ETHZ_WHITE,
    [308] = ETHZ_WHITE,
    [311] = ETHZ_WHITE,
    [314] = ETHZ_WHITE,
    [316] = ETHZ_WHITE,
    [318] = ETHZ_WHITE,
    [319] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 4
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_4[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [174] = ETHZ_WHITE,
    [175] = ETHZ_WHITE,
    [176] = ETHZ_WHITE,
    [178] = ETHZ_WHITE,
    [179] = ETHZ_WHITE,
    [180] = ETHZ_WHITE,
    [182] = ETHZ_WHITE,
    [184] = ETHZ_WHITE,
    [186] = ETHZ_WHITE,
    [187] = ETHZ_WHITE,
    [188] = ETHZ_WHITE,
    [206] = ETHZ_WHITE,
    [211] = ETHZ_WHITE,
    [214] = ETHZ_WHITE,
    [216] = ETHZ_WHITE,
    [220] = ETHZ_WHITE,
    [238] = ETHZ_WHITE,
    [239] = ETHZ_WHITE,
    [243] = ETHZ_WHITE,
    [246] = ETHZ_WHITE,
    [247] = ETHZ_WHITE,
    [248] = ETHZ_WHITE,
    [251] = ETHZ_WHITE,
    [270] = ETHZ_WHITE,
    [275] = ETHZ_WHITE,
    [278] = ETHZ_WHITE,
    [280] = ETHZ_WHITE,
    [282] = ETHZ_WHITE,
    [302] = ETHZ_WHITE,
    [303] = ETHZ_WHITE,
    [304] = ETHZ_WHITE,
    [307] = ETHZ_WHITE,
    [310] = ETHZ_WHITE,
    [312] = ETHZ_WHITE,
    [314] = ETHZ_WHITE,
    [315] = ETHZ_WHITE,
    [316] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 5
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_5[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [170] = ETHZ_WHITE,
    [171] = ETHZ_WHITE,
    [172] = ETHZ_WHITE,
    [174] = ETHZ_WHITE,
    [175] = ETHZ_WHITE,
    [176] = ETHZ_WHITE,
    [178] = ETHZ_WHITE,
    [180] = ETHZ_WHITE,
    [182] = ETHZ_WHITE,
    [183] = ETHZ_WHITE,
    [184] = ETHZ_WHITE,
    [202] = ETHZ_WHITE,
    [207] = ETHZ_WHITE,
    [210] = ETHZ_WHITE,
    [212] = ETHZ_WHITE,
    [216] = ETHZ_WHITE,
    [234] = ETHZ_WHITE,
    [235] = ETHZ_WHITE,
    [239] = ETHZ_WHITE,
    [242] = ETHZ_WHITE,
    [243] = ETHZ_WHITE,
    [244] = ETHZ_WHITE,
    [247] = ETHZ_WHITE,
    [266] = ETHZ_WHITE,
    [271] = ETHZ_WHITE,
    [274] = ETHZ_WHITE,
    [276] = ETHZ_WHITE,
    [278] = ETHZ_WHITE,
    [298] = ETHZ_WHITE,
    [299] = ETHZ_WHITE,
    [300] = ETHZ_WHITE,
    [303] = ETHZ_WHITE,
    [306] = ETHZ_WHITE,
    [308] = ETHZ_WHITE,
    [310] = ETHZ_WHITE,
    [311] = ETHZ_WHITE,
    [312] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 6
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_6[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [166] = ETHZ_WHITE,
    [167] = ETHZ_WHITE,
    [168] = ETHZ_WHITE,
    [170] = ETHZ_WHITE,
    [171] = ETHZ_WHITE,
    [172] = ETHZ_WHITE,
    [174] = ETHZ_WHITE,
    [176] = ETHZ_WHITE,
    [178] = ETHZ_WHITE,
    [179] = ETHZ_WHITE,
    [180] = ETHZ_WHITE,
    [198] = ETHZ_WHITE,
    [203] = ETHZ_WHITE,
    [206] = ETHZ_WHITE,
    [208] = ETHZ_WHITE,
    [212] = ETHZ_WHITE,
    [230] = ETHZ_WHITE,
    [231] = ETHZ_WHITE,
    [235] = ETHZ_WHITE,
    [238] = ETHZ_WHITE,
    [239] = ETHZ_WHITE,
    [240] = ETHZ_WHITE,
    [243] = ETHZ_WHITE,
    [262] = ETHZ_WHITE,
    [267] = ETHZ_WHITE,
    [270] = ETHZ_WHITE,
    [272] = ETHZ_WHITE,
    [274] = ETHZ_WHITE,
    [294] = ETHZ_WHITE,
    [295] = ETHZ_WHITE,
    [296] = ETHZ_WHITE,
    [299] = ETHZ_WHITE,
    [302] = ETHZ_WHITE,
    [304] = ETHZ_WHITE,
    [306] = ETHZ_WHITE,
    [307] = ETHZ_WHITE,
    [308] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 7
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_7[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [162] = ETHZ_WHITE,
    [163] = ETHZ_WHITE,
    [164] = ETHZ_WHITE,
    [166] = ETHZ_WHITE,
    [167] = ETHZ_WHITE,
    [168] = ETHZ_WHITE,
    [170] = ETHZ_WHITE,
    [172] = ETHZ_WHITE,
    [174] = ETHZ_WHITE,
    [175] = ETHZ_WHITE,
    [176] = ETHZ_WHITE,
    [194] = ETHZ_WHITE,
    [199] = ETHZ_WHITE,
    [202] = ETHZ_WHITE,
    [204] = ETHZ_WHITE,
    [208] = ETHZ_WHITE,
    [226] = ETHZ_WHITE,
    [227] = ETHZ_WHITE,
    [231] = ETHZ_WHITE,
    [234] = ETHZ_WHITE,
    [235] = ETHZ_WHITE,
    [236] = ETHZ_WHITE,
    [239] = ETHZ_WHITE,
    [258] = ETHZ_WHITE,
    [263] = ETHZ_WHITE,
    [266] = ETHZ_WHITE,
    [268] = ETHZ_WHITE,
    [270] = ETHZ_WHITE,
    [290] = ETHZ_WHITE,
    [291] = ETHZ_WHITE,
    [292] = ETHZ_WHITE,
    [295] = ETHZ_WHITE,
    [298] = ETHZ_WHITE,
    [300] = ETHZ_WHITE,
    [302] = ETHZ_WHITE,
    [303] = ETHZ_WHITE,
    [304] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 8
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_8[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [160] = ETHZ_WHITE,
    [162] = ETHZ_WHITE,
    [163] = ETHZ_WHITE,
    [164] = ETHZ_WHITE,
    [166] = ETHZ_WHITE,
    [168] = ETHZ_WHITE,
    [170] = ETHZ_WHITE,
    [171] = ETHZ_WHITE,
    [172] = ETHZ_WHITE,
    [195] = ETHZ_WHITE,
    [198] = ETHZ_WHITE,
    [200] = ETHZ_WHITE,
    [204] = ETHZ_WHITE,
    [227] = ETHZ_WHITE,
    [230] = ETHZ_WHITE,
    [231] = ETHZ_WHITE,
    [232] = ETHZ_WHITE,
    [235] = ETHZ_WHITE,
    [259] = ETHZ_WHITE,
    [262] = ETHZ_WHITE,
    [264] = ETHZ_WHITE,
    [266] = ETHZ_WHITE,
    [288] = ETHZ_WHITE,
    [291] = ETHZ_WHITE,
    [294] = ETHZ_WHITE,
    [296] = ETHZ_WHITE,
    [298] = ETHZ_WHITE,
    [299] = ETHZ_WHITE,
    [300] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 9
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_9[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [161] = ETHZ_WHITE,
    [163] = ETHZ_WHITE,
    [165] = ETHZ_WHITE,
    [166] = ETHZ_WHITE,
    [167] = ETHZ_WHITE,
    [193] = ETHZ_WHITE,
    [195] = ETHZ_WHITE,
    [199] = ETHZ_WHITE,
    [225] = ETHZ_WHITE,
    [226] = ETHZ_WHITE,
    [227] = ETHZ_WHITE,
    [230] = ETHZ_WHITE,
    [257] = ETHZ_WHITE,
    [259] = ETHZ_WHITE,
    [261] = ETHZ_WHITE,
    [289] = ETHZ_WHITE,
    [291] = ETHZ_WHITE,
    [293] = ETHZ_WHITE,
    [294] = ETHZ_WHITE,
    [295] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 10
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_10[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
    [161] = ETHZ_WHITE,
    [162] = ETHZ_WHITE,
    [163] = ETHZ_WHITE,
    [195] = ETHZ_WHITE,
    [226] = ETHZ_WHITE,
    [257] = ETHZ_WHITE,
    [289] = ETHZ_WHITE,
    [290] = ETHZ_WHITE,
    [291] = ETHZ_WHITE,
};


// -----------------------------------------------------------------------------
// Frame 11
// -----------------------------------------------------------------------------

static const uint16_t ethz_frame_11[
    ETHZ_FRAME_WIDTH * ETHZ_FRAME_HEIGHT
] __attribute__((aligned(8))) = {
};


// -----------------------------------------------------------------------------
// Frame table
// -----------------------------------------------------------------------------

static const uint16_t *const ethz_frames[] = {
    ethz_frame_0,
    ethz_frame_1,
    ethz_frame_2,
    ethz_frame_3,
    ethz_frame_4,
    ethz_frame_5,
    ethz_frame_6,
    ethz_frame_7,
    ethz_frame_8,
    ethz_frame_9,
    ethz_frame_10,
    ethz_frame_11,
};


#define ETHZ_NUM_FRAMES \
    (sizeof(ethz_frames) / sizeof(ethz_frames[0]))