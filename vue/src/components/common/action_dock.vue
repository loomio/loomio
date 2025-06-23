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
    }
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
    action-button(v-if="name != 'react'" :action="action" :name="name" :size="size" :nameArgs="action.nameArgs && action.nameArgs()")
  v-spacer(v-if="!left")
  reaction-display(:model="model" v-if="!left && actions.react" :canEdit="actions.react.canPerform()" :size="size")
  .action-dock__action(v-for='(action, name) in rightActions' :key="name")
    reaction-input.action-dock__button--react(:model="model" v-if="name == 'react'", :size="size")
    action-button(v-if="name != 'react'" :action="action" :name="name" :size="size" :nameArgs="action.nameArgs && action.nameArgs()")
  action-menu(v-if="menuActions" :actions='menuActions' :menuIcon="menuIcon" :size="size" icon :name="$t('action_dock.more_actions')")
  v-spacer(v-if="left")
  reaction-display(:model="model" v-if="left && actions.react" :canEdit="actions.react.canPerform()" :size="size")
</template>

<style lang="sass">
.action-dock__action, .action-menu
  transition: opacity ease-in-out 0.25s

.lmo-action-dock-wrapper
  .action-dock__action, .action-menu
    opacity: 0.66
  &:hover .action-dock__action, &:hover .action-menu
    opacity: 1

</style>
