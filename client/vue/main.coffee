Vue =   require('vue')
Vue.use require('vue-material')

{ exportGlobals } = require 'shared/helpers/window.coffee'

exportGlobals()

app = new Vue(
  el: '#vue-app',
  components:
    root_component: require('./components/root_component.vue')
    poll_form:      require('./components/poll_form.vue')
)
