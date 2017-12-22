Vue = require 'vue'

app = new Vue(
  el: '#vue-app',
  components:
    root_component: require('vue/components/root_component.vue')
)
