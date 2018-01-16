Vue =   require('vue')
Vue.use require('vue-material')

{ exportGlobals } = require 'shared/helpers/window.coffee'
{ setupVue }      = require './setup.coffee'

exportGlobals()
setupVue()

app = new Vue(
  el: '#vue-app',
  components:
    root_component: require('./components/root_component.vue')
    start_poll:     require('./components/workflows/start_poll.vue')
    enter_type:     require('./components/workflows/start_poll/enter_type.vue')
    enter_details:  require('./components/workflows/start_poll/enter_details.vue')
    enter_options:  require('./components/workflows/start_poll/enter_options.vue')
)
