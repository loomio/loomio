<script lang="coffee">
export default
  props:
    action: Object
    name: String
    nameArgs: Object
    small: Boolean
  computed:
    text: -> @$t((@action.name || 'action_dock.'+@name), (@nameArgs || {}))
    cssClass: -> "action-dock__button--#{@name}"
</script>

<template lang="pug">
span
  v-btn.action-button(v-if="action.to" :small="small" :to="action.to()" text :icon="action.dock == 1" :title="text" :class='cssClass' )
    v-icon(v-if="action.dock == 1 || action.dock == 3" :small="small") {{action.icon}}
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
  v-btn.action-button(v-else :small="small" @click.prevent="action.perform()" text :icon="action.dock == 1" :title="text" :class='cssClass' )
    v-icon(v-if="action.dock == 1 || action.dock == 3" :small="small") {{action.icon}}
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
