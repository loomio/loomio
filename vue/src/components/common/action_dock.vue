<script lang="coffee">
export default
  props:
    model: Object
    actions: Object
</script>

<template lang="pug">
.action-dock.lmo-no-print
  .action-dock__action.mr-1(v-for='(action, name) in actions' v-if='action.canPerform()' :key="name")
    reaction-input.action-dock__button--react(:model="model" v-if="name == 'react'")
    v-tooltip(bottom v-if="name != 'react'")
      template(v-slot:activator="{ on }")
        v-btn(v-on="on" small icon :class='`action-dock__button--${name}`' @click.prevent='action.perform()')
          v-icon {{action.icon}}
      span(v-t="action.name || 'action_dock.'+name")
</template>

<style lang="sass">
.action-dock
  display: flex
.action-dock, .action-menu
  transition: opacity ease-in-out 0.25s

.lmo-action-dock-wrapper
  .action-dock, .action-menu
    opacity: 0.5
  &:hover .action-dock, &:hover .action-menu
    opacity: 1

</style>
