import Vue from 'vue'
import Vuetify from 'vuetify'
import colors from 'vuetify/es5/util/colors'
import 'vuetify/src/stylus/app.styl'

Vue.use(Vuetify,
  iconfont: 'mdi'
  theme:
    primary: colors.amber.base
    secondary: colors.green.base
    accent: colors.cyan.base
  options:
    customProperties: true
)
