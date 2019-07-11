<script lang="coffee">
export default
  props:
    model: Object
    actions: Object
  created: ->
    console.log @actions
</script>

<template lang="pug">
.action-dock.lmo-no-print
  .action-dock__action(v-for='(action, name) in actions' v-if='action.canPerform()' :key="name")
    reaction-input.action-dock__button--react(:model="model" v-if="name == 'react'")
    v-tooltip(bottom v-if="name != 'react'")
      template(v-slot:activator="{ on }")
        v-btn(v-on="on" icon :title="$t('action_dock.' + name)" :class='`action-dock__button--${name}`' @click='action.perform()')
          v-icon {{action.icon}}
      span(v-t="'action_dock.'+name")
</template>

<style lang="sass">
.action-dock
  display: flex
.action-dock, .action-menu
  transition: opacity ease-in-out 0.25s

.lmo-action-dock-wrapper
  .action-dock, .action-menu
    opacity: 0.3
  &:hover .action-dock, &:hover .action-menu
    opacity: 1

</style>
