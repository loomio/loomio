<script lang="coffee">
export default
  props:
    model: Object
    actions: Object
    menuActions: Object
    fetchReactions: Boolean
</script>

<template lang="pug">
div.d-flex.justify-end.align-center.flex-wrap
  reaction-display(:model="model" v-if="Object.keys(actions).includes('react')" :fetch="fetchReactions")
  .action-dock__action(v-for='(action, name) in actions' v-if='action.canPerform()' :key="name")
    reaction-input.action-dock__button--react(:model="model" v-if="name == 'react'")
    action-button(v-if="name != 'react'" :action="action" :name="name")
  action-menu(v-if="menuActions" :actions='menuActions')
</template>

<style lang="sass">
.action-dock__action, .action-menu
  transition: opacity ease-in-out 0.25s

.lmo-action-dock-wrapper
  .action-dock__action, .action-menu
    opacity: 0.5
  &:hover .action-dock__action, &:hover .action-menu
    opacity: 1

</style>
