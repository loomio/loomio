import 'vuetify/styles'

// Composables
import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi-svg'

const useDarkMode = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);

const colors = {
  gold: "#DCA034",
  goldDarker: "#C6902F",
  ink: "#293C4A",
  wellington: "#7F9EA0",
  sunset: "#E4C2B9",
  sky: "#658AE7",
  skyDarker: "#5B7CD0",
  rock: "#C77C3B",
  white: "#FFFFFF"
}

export default createVuetify({
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: { mdi },
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        dark: false,
        colors: {
          primary:  colors.skyDarker,
          secondary:  colors.skyDarker,
          accent:  colors.skyDarker,
          // error: ENV.fetch('THEME_COLOR_ERROR', nil),
          // warning: ENV.fetch('THEME_COLOR_WARNING', nil),
          info:  colors.skyDarker,
          // success: ENV.fetch('THEME_COLOR_SUCCESS', nil),
          anchor:  colors.skyDarker,
        },
      },
      dark: {
        dark: true,
        colors: {
          primary: colors.gold,
          secondary: colors.skyDarker,
          accent: colors.skyDarker,
          // error: ENV.fetch('THEME_COLOR_ERROR', nil),
          // warning: ENV.fetch('THEME_COLOR_WARNING', nil),
          info: colors.gold,
          // success: ENV.fetch('THEME_COLOR_SUCCESS', nil),
          anchor: colors.gold
        },
      },
    },
  },
})
