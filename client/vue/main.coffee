Vue =   require('vue')
Vue.use require('vue-material')

require 'vue-material/dist/vue-material.min.css'

app = new Vue(
  el: '#vue-app',
  components:
    root_component: require('./components/root_component.vue')
    poll_form:      require('./components/poll_form.vue')
)
