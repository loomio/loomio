<script lang="coffee">
export default
  props:
    icons: Boolean
    model: Object
    actions: Object
    menuActions: Object
    fetchReactions: Boolean
    small: Boolean
    left: Boolean
</script>

<template lang="pug">
section.d-flex.align-center.action-dock(:aria-label="$t('action_dock.actions_menu')")
  v-spacer(v-if="!left")
  reaction-display(:model="model" v-if="Object.keys(actions).includes('react')" :fetch="fetchReactions" :small="small")
  .action-dock__action(v-for='(action, name) in actions' v-if='action.canPerform()' :key="name")
    reaction-input.action-dock__button--react(:model="model" v-if="name == 'react'" :icon="icons" :small="small")
    action-button(v-if="name != 'react'" :icon="icons" :action="action" :name="name" :small="small" :nameArgs="action.nameArgs && action.nameArgs()")
  action-menu(v-if="menuActions" :actions='menuActions' :small="small")
  v-spacer(v-if="left")
</template>

<style lang="sass">
.action-dock__action, .action-menu
  transition: opacity ease-in-out 0.25s

.lmo-action-dock-wrapper
  .action-dock__action, .action-menu
    opacity: 0.35
  &:hover .action-dock__action, &:hover .action-menu
    opacity: 1

</style>
