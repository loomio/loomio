<script lang="js">
import {pickBy} from 'lodash-es';

export default {
  props: {
    model: Object,
    actions: {
      type: Object,
      default() { return {}; }
    },
    menuActions: {
      type: Object,
      default() { return {}; }
    },
    size: {
      type: String,
      default: 'default',
    },
    left: Boolean,
    menuIcon: {
      type: String,
      default: 'mdi-dots-horizontal'
    },
    color: {
      type: String,
      default: undefined
    },
    variant: {
      type: String,
      default: 'text'
    },
  },

  computed: {
    leftActions() {
      return pickBy(this.actions, v => (v.dockLeft && v.canPerform()));
    },

    rightActions() {
      return pickBy(this.actions, v => (!v.dockLeft && v.canPerform()));
    }
  }
};
</script>

<template lang="pug">
section.d-flex.flex-wrap.align-center.action-dock.pb-1(style="margin-left: -6px" :aria-label="$t('action_dock.actions_menu')")
  .action-dock__action(v-for='(action, name) in leftActions' :key="name")
    action-button(
      v-if="name != 'react'"
      :action="action"
      :name="name"
      :nameArgs="action.nameArgs && action.nameArgs()"
      :color="color"
      :variant="variant"
      :size="size"
    )
  v-spacer(v-if="!left")
  reaction-display(
    v-if="!left && actions.react"
    :model="model"
    :color="color"
    :variant="variant"
    :canEdit="actions.react.canPerform()"
    :size="size"
  )
  .action-dock__action.mb-1(v-for='(action, name) in rightActions' :key="name")
    reaction-input.action-dock__button--react(
      v-if="name == 'react'"
      :model="model"
      :color="color"
      :variant="variant"
      :size="size"
    )
    action-button(
      v-if="name != 'react'"
      :action="action"
      :name="name"
      :nameArgs="action.nameArgs && action.nameArgs()"
      :color="color"
      :variant="variant"
      :size="size"
    )
  action-menu.mb-1(
    v-if="menuActions"
    :actions='menuActions'
    :menuIcon="menuIcon"
    :name="$t('action_dock.more_actions')"
    icon
    :color="color"
    :variant="variant"
    :size="size"
  )
  template(v-if="left")
    v-spacer
    reaction-display(:model="model" v-if="actions.react" :canEdit="actions.react.canPerform()" :size="size")
</template>
