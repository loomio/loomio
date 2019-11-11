import Vue from 'vue'
import Vuetify from 'vuetify/lib'

Vue.use(Vuetify)

import colors from 'vuetify/lib/util/colors'

export default new Vuetify(
  iconfont: 'mdi'
  theme:
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
        background: '#fafafa'
    options:
      customProperties: true
)
