<script lang="js">
import I18n from '@/i18n';

export default {
  props: {
    action: Object,
    name: String,
    nameArgs: Object,
    size: {
      type: String,
      default: 'default'
    }
  },
  computed: {
    text() { return I18n.global.t((this.action.name || ('action_dock.'+this.name)), (this.nameArgs || {})); },
    cssClass() { return `action-dock__button--${this.name}`; }
  }
};
</script>

<template lang="pug">
span
  v-btn.action-button(v-if="action.to" :size="size" :to="action.to()" variant="text" :icon="action.dock == 1" :title="text" :class='cssClass' )
    common-icon(v-if="action.dock == 1 || action.dock == 3" :size="size" :name="action.icon")
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
  v-btn.action-button(v-else :size="size" @click.prevent="action.perform()" variant="text" :icon="action.dock == 1" :title="text" :class='cssClass' )
    common-icon(v-if="action.dock == 1 || action.dock == 3" :size="size" :name="action.icon")
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
