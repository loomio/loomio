<style lang="scss">
@import 'lmo_card';

.thread-previews-container {
  @include cardNoPadding;
  margin-bottom: $cardPaddingSize;
  margin-top: $thinPaddingSize;
}

.thread-previews {
  border-top: 1px solid $border-color;
}

</style>

<script lang="coffee">
module.exports =
  props:
    query: Object
    limit:
      type: Number
      default: 25
    order:
      type: String
      default: '-lastActivityAt'
  data: ->
    threads: @query.threads()
  computed:
    orderedThreads: ->
      _.slice(_.orderBy(@threads, @order), 0, @limit)
</script>

<template>
    <div class="thread-previews">
      <div v-for="thread in orderedThreads" :key="thread.id" class="blank">
        <thread-preview :thread="thread"></thread-preview>
      </div>
    </div>
</template>
