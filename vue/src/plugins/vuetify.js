// Composables
import { createVuetify } from 'vuetify'
import { md3 } from 'vuetify/blueprints'
import { aliases, mdi } from 'vuetify/iconsets/mdi-svg'
const colors = {
  yellow50: "#FFF7E0",
  yellow425: "#F5C401",
  bluegoo: "#f0f4f9",
  blue25: "#F5FAFF",
  blue35: "#F1F8FF",
  blue50: "#EBF4FF",
  blue300: "#4DA3FF",
  blue400: "#1F87FF",
  blue500: "#0070E0",
  green50: "#EDFAF3",
  green600: "#0D7A3C",
  red50: "#FEF1F1",
  red500: "#D43030",
  grey50: "#F5F5F5",
  grey100: "#E8E8E8",
  white: "#FFFFFF",
}

export default createVuetify({
  blueprint: md3,
  defaults: {
    VBtn: {
      color: undefined,
    },
    VCheckbox: {
      color: 'primary',
    },
  },
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: { mdi },
  },
  theme: {
    defaultTheme: 'system',
    themes: {
      light: {
        dark: false,
        colors: {
          background: colors.blue50,
          surface: colors.white,
          primary: colors.blue500,
          accent: colors.yellow425,
          info: colors.blue500,
          success: colors.green600,
          error: colors.red500,
          warning: colors.yellow425,
          anchor: colors.blue500,
        },
      },

      dark: {
        dark: true,
        colors: {
          primary: colors.yellow425,
          accent: colors.yellow425,
          info: colors.blue300,
          success: colors.green600,
          error: colors.red500,
          warning: colors.yellow425,
          anchor: colors.yellow425,
        },
      },
    },
  },
})
