<style lang="scss">
.time-ago {
  border: 0;
}
</style>

<script lang="coffee">
export default
  params: ['date']
  computed:
    ago: ->
      moment(@date).fromNow()
</script>

<template>
    <abbr class="timeago"><span>{{ ago }}</span></abbr>
</template>
