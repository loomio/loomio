<style lang="scss">
.time-ago {
  border: 0;
}
</style>

<script lang="coffee">
export default
  props:
    date: Object
  methods:
    ago: ->
      moment(@date).fromNow()
</script>

<template>
    <abbr class="timeago"><span>{{ ago() }}</span></abbr>
</template>
