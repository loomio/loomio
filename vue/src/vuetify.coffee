import Vue from 'vue'
import Vuetify from 'vuetify/lib'
import '@mdi/font/css/materialdesignicons.css'

Vue.use(Vuetify)

import colors from 'vuetify/lib/util/colors'

useDarkMode = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)


export default new Vuetify(
  iconfont: 'mdi'
  theme:
    # dark: useDarkMode
    themes:
      light:
        primary: colors.amber.darken1
        secondary: colors.pink.lighten2
        accent: colors.cyan.base
        error: colors.deepOrange.base
        warning: colors.red.base
        info: colors.lightBlue.base
        success: colors.green.base
        anchor: colors.cyan.base
    options:
      customProperties: true
)
