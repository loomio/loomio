<script lang="coffee">
export default
  props:
    action: Object
    name: String
    nameArgs: Object
    icon: Boolean
    small: Boolean
  computed:
    useIcon: -> !!(@icon && @action.icon)
    text: -> @$t(@action.name || 'action_dock.'+@name, @nameArgs || {})
    cssClass: -> "action-dock__button--#{@name}"
</script>

<template lang="pug">
span
  v-btn.action-button(v-if="action.to" :small="small" :to="action.to()" :text="!useIcon" :icon="useIcon" :title="text" :class='cssClass' )
    v-icon(v-if="useIcon" :small="small") {{action.icon}}
    span(v-else) {{text}}
  v-btn.action-button(v-else :small="small" @click.prevent="action.perform()" :text="!useIcon" :icon="useIcon" :title="text" :class='cssClass' )
    v-icon(v-if="useIcon" :small="small") {{action.icon}}
    span(v-else) {{text}}
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
