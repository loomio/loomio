import Vue from 'vue'
import Vuetify from 'vuetify/lib'
import '@mdi/font/css/materialdesignicons.css'
import Session         from '@/shared/services/session'

Vue.use(Vuetify)

import colors from 'vuetify/lib/util/colors'

useDarkMode = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)


export default new Vuetify(
  iconfont: 'mdi'
  theme:
    dark: false
    options:
      customProperties: true
    # themes:
    #   light:
    #     primary: colors.amber.darken1
    #     secondary: colors.pink.lighten2
    #     accent: colors.cyan.base
    #     error: colors.red.base
    #     warning: colors.orange.base
    #     info: colors.lightBlue.base
    #     success: colors.green.base
    #     anchor: colors.cyan.base
)
