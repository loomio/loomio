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
    action-button(v-if="name != 'react'" :action="action" :name="name")
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
