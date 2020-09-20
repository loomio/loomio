<script lang="coffee">
export default
  props:
    action: Object
    name: String
    nameArgs: Object
    icon: Boolean
</script>

<template lang="pug">
span
  v-icon(v-if="icon") {{action.icon}}
  template(v-else)
    v-btn.action-button(v-if="action.to" :to="action.to()" small text v-t="{path: (action.name || 'action_dock.'+name), args: (nameArgs || {})}" :class='`action-dock__button--${name}`' )
    v-btn.action-button(v-else @click.prevent="action.perform()" small text v-t="{path: (action.name || 'action_dock.'+name), args: (nameArgs || {})}" :class='`action-dock__button--${name}`' )
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
