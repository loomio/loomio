<script lang="js">
export default {
  props: {
    action: Object,
    name: String,
    nameArgs: Object,
    color: String,
    variant: String,
    size: {
      type: String,
      default: undefined
    }
  },
  computed: {
    text() { return this.$t((this.action.name || ('action_dock.'+this.name)), (this.nameArgs || {})); },
    cssClass() { return `action-dock__button--${this.name}`; }
  }
};
</script>

<template lang="pug">
span
  v-btn.action-button.mr-1(
    v-if="action.to"
    :to="action.to()"
    :icon="action.dock == 1"
    :title="text"
    :class='cssClass'
    :color="color"
    :variant="variant"
    :density="action.dock == 1 ? 'comfortable' : 'default'"
    :size="size"
  )
    common-icon(v-if="action.dock == 1 || action.dock == 3" :size="size" :name="action.icon" :color="color")
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
  v-btn.action-button.mr-1(
    v-else
    @click.prevent="action.perform()"
    :icon="action.dock == 1"
    :title="text"
    :class='cssClass'
    :color="color"
    :size="size"
    :density="action.dock == 1 ? 'comfortable' : 'default'"
    :variant="variant"
  )
    common-icon(v-if="action.dock == 1 || action.dock == 3" :size="size" :name="action.icon" :color="color")
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
