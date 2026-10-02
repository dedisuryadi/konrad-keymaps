// Copyright 2026 QuadSmack
// SPDX-License-Identifier: GPL-2.0-or-later

#include QMK_KEYBOARD_H

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT(
        KC_Q,    KC_W,         KC_K,         KC_P,         KC_B,          KC_J,          KC_L,          KC_U,          KC_Y,          KC_QUOT,
        KC_ESC,  LCTL_T(KC_A), LALT_T(KC_R), LGUI_T(KC_S), LSFT_T(KC_T), HYPR_T(KC_G),   HYPR_T(KC_M),  LSFT_T(KC_N),  LGUI_T(KC_E),  LALT_T(KC_I),  LCTL_T(KC_O), KC_SCLN,
        QK_BOOT, KC_Z,         KC_X,         KC_C,         KC_D,          KC_V,          KC_F,          KC_H,          KC_COMM,       KC_DOT,        KC_SLSH,       QK_BOOT,
                                               MS_BTN1, KC_SPC, KC_TAB,   KC_BSPC, KC_ENT, KC_DEL
    )
};
