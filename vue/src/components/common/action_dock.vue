<script lang="coffee">
import { filter, includes, without } from 'lodash'

export default
  props:
    model: Object
    actions: Array

  data: ->
    primaryNames: ['reply_to_comment', 'react']

  computed:
    canPerformActions: ->
      any(@actions, (action) -> action.canPerform())

    primaryActions: ->
      filter @actions, (action) =>
        includes(@primaryNames, action.name)

    secondaryActions: ->
      filter @actions, (action) =>
        !includes(@primaryNames, action.name)


</script>

<template lang="pug">
.lmo-action-dock-wrapper(v-if="canPerformActions")
  .action-dock.lmo-no-print
    .action-dock__action(v-for='action in primaryActions' v-if='action.canPerform()' :key="action.name")
      reaction-input.action-dock__button--react(:model="model" v-if="action.name == 'react'")
      v-tooltip(bottom v-if="action.name != 'react'")
        v-btn(slot='activator' icon :class='`md-button--tiny action-dock__button--${action.name}`' v-if="action.name != 'react'" @click='action.perform()')
          .sr-only(v-t="'action_dock.' + action.name")
          v-icon {{action.icon}}
          div(v-if='action.active && action.active()', md-colors="{'color': 'warn-200'}")
            i.mdi.mdi-alert-circle-outline.mdi-16px.lmo-margin-right
            span(v-t="'action_dock.' + action.name + '_active'", v-if='action.active && action.active()')
        div(v-t="'action_dock.' + action.name")
    v-menu(v-if="secondaryActions.length" bottom left)
      template(v-slot:activator="{ on }")
        v-btn(icon v-on="on")
          v-icon mdi-dots-vertical
      v-list
        v-list-tile(v-for="action in secondaryActions" v-if='action.canPerform()' :key="action.name" @click="action.perform()")
          v-list-tile-title(v-t="'action_dock.' + action.name")
</template>

<style lang="scss">
.action-dock {
  display: flex;
  align-items: center;
  transition: opacity ease-in-out 0.25s;
}
</style>
