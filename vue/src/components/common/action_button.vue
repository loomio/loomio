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
  v-btn.action-button(v-if="action.to" :to="action.to()" small :text="!icon" :icon="icon" :title="$t(action.name || 'action_dock.'+name, nameArgs || {})" :class='`action-dock__button--${name}`' )
    span(v-if="!icon" v-t="{path: (action.name || 'action_dock.'+name), args: (nameArgs || {})}")
    v-icon(v-if="icon") {{action.icon}}
  v-btn.action-button(v-else @click.prevent="action.perform()" small :text="!icon" :icon="icon" :title="$t(action.name || 'action_dock.'+name, nameArgs || {})" :class='`action-dock__button--${name}`' )
    span(v-if="!icon" v-t="{path: (action.name || 'action_dock.'+name), args: (nameArgs || {})}")
    v-icon(v-if="icon") {{action.icon}}
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
