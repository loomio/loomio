<script lang="js">
export default {
  props: {
    action: Object,
    name: String,
    nameArgs: Object,
    small: Boolean
  },
  computed: {
    text() { return this.$t((this.action.name || ('action_dock.'+this.name)), (this.nameArgs || {})); },
    cssClass() { return `action-dock__button--${this.name}`; }
  }
};
</script>

<template>
<span>
  <v-btn class="action-button" v-if="action.to" :small="small" :to="action.to()" text="text" :icon="action.dock == 1" :title="text" :class="cssClass">
    <common-icon v-if="action.dock == 1 || action.dock == 3" :small="small" :name="action.icon"></common-icon><span class="ml-1" v-if="action.dock == 3"></span><span v-if="action.dock > 1">{{text}}</span>
  </v-btn>
  <v-btn class="action-button" v-else :small="small" @click.prevent="action.perform()" text="text" :icon="action.dock == 1" :title="text" :class="cssClass">
    <common-icon v-if="action.dock == 1 || action.dock == 3" :small="small" :name="action.icon"></common-icon><span class="ml-1" v-if="action.dock == 3"></span><span v-if="action.dock > 1">{{text}}</span>
  </v-btn></span>
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
