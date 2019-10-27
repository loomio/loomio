<script lang="coffee">
export default
  props:
    action: Object
    name: Object
</script>

<template lang="pug">
v-btn.action-button(small text v-t="action.name || 'action_dock.'+name" :class='`action-dock__button--${name}`' @click.prevent='action.perform()')
</template>

<style lang="sass">
.action-button
  text-transform: lowercase

</style>
