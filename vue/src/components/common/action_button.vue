<script lang="coffee">
export default
  props:
    action: Object
    name: String
    nameArgs: Object
    icon: Boolean
</script>

<template lang="pug">
v-btn.action-button(small text :icon="icon" :class='`action-dock__button--${name}`' @click.prevent='action.perform()')
  v-icon(v-if="icon") {{action.icon}}
  span(v-else v-t="{path: (action.name || 'action_dock.'+name), args: (nameArgs || {})}")
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
