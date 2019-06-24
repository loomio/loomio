<style lang="scss">
.time-ago { border: 0; }
.timeago{
  white-space: nowrap;
}

</style>

<script lang="coffee">
export default
  props:
    date: Object

  methods:
    timeAgo: ->
      console.log @date, moment(@date).fromNow()
      moment(@date).fromNow()

</script>
<template lang="pug">
span(v-t="{path: 'common.active_time_ago', args: {time_ago: timeAgo()}}")
</template>
