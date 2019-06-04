<script lang="coffee">
export default
  props:
    model: Object
    actions: Array
</script>

<template lang="pug">
.lmo-action-dock-wrapper
  .action-dock.lmo-no-print
    .action-dock__action(v-for='action in actions', v-if='action.canPerform()')
      reaction-input.action-dock__button--react(:model="model" v-if="action.name == 'react'")
      v-tooltip(bottom)
        v-btn(slot='activator' icon :class='`md-button--tiny action-dock__button--${action.name}`' v-if="action.name != 'react'" @click='action.perform()')
          .sr-only(v-t="'action_dock.' + action.name")
          v-icon {{action.icon}}
          div(v-if='action.active && action.active()', md-colors="{'color': 'warn-200'}")
            i.mdi.mdi-alert-circle-outline.mdi-16px.lmo-margin-right
            span(v-t="'action_dock.' + action.name + '_active'", v-if='action.active && action.active()')
        div(v-t="'action_dock.' + action.name")
</template>

<style lang="scss">
.action-dock {
  display: flex;
  align-items: center;
  transition: opacity ease-in-out 0.25s;
}
</style>
