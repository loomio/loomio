<style lang="css">
.poll-common-percent-voted {
  margin: 16px 0;
}
</style>

<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template>
    <div v-if="poll.membersCount() > 0" class="poll-common-percent-voted lmo-hint-text">
      <span v-t="{ path: 'poll_common_percent_voted.sentence', args: { numerator: poll.stancesCount, denominator: poll.membersCount(), percent: poll.percentVoted() } }"></span>
    </div>
</template>
