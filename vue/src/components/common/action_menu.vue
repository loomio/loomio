<script lang="coffee">
import { some } from 'lodash'
export default
  props:
    model: Object
    actions: Object

  computed:
    canPerformAny: ->
      some @actions, (action) -> action.canPerform()

</script>

<template lang="pug">
.action-menu.lmo-no-print
  v-menu(v-if='canPerformAny')
    template(v-slot:activator="{ on }")
      v-btn(icon v-on="on")
        v-icon mdi-dots-vertical
    v-list
      v-list-item(v-for="(action, name) in actions" :key="name" @click="action.perform()" v-if='action.canPerform()')
        v-list-item-title(v-t="'action_dock.'+name")
</template>
