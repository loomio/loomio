import 'vuetify/styles'

process.env

// Composables
import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi-svg'
import { VDateInput } from 'vuetify/labs/VDateInput'


const colors = {
  gold: "#DCA034",
  goldDark1: "#C6902F",
  ink: "#293C4A",
  wellington: "#7F9EA0",
  sunset: "#E4C2B9",
  sky: "#658AE7",
  skyDark1: "#5B7CD0",
  skyDark2: "#516EB9",
  skyDark3: "#516EB9",
  rock: "#C77C3B",
  white: "#FFFFFF"
}

export default createVuetify({
  components: {
    VDateInput,
  },
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
          background: "#fcf6eb",
          primary:  colors.goldDark1,
          info:  colors.skyDark1,
          anchor:  colors.goldDark1,
        },
      },

      dark: {
        dark: true,
        colors: {
          primary: colors.gold,
          info: colors.skyDark1,
          anchor: colors.gold
        },
      },

      lightBlue: {
        dark: false,
        colors: {
          background: "#f0f0f0",
          primary:  colors.skyDark1,
          info:   colors.skyDark1,
          anchor:  colors.skyDark2,
        },
      },

      darkBlue: {
        dark: true,
        colors: {
          primary: colors.sky,
          info: colors.skyDark1,
          anchor: colors.sky
        },
      },
    },
  },
})
