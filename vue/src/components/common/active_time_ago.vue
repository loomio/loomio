<script lang="coffee">
export default
  props:
    date: Object

  methods:
    timeAgo: ->
      moment(@date).fromNow()

</script>
<template lang="pug">
span(v-t="{path: 'common.active_time_ago', args: {time_ago: timeAgo()}}")
</template>
