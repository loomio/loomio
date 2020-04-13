<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template>
  <span v-t="{ path: 'poll_common_percent_voted.sentence', args: { numerator: poll.participantsCount, denominator: poll.stancesCount, percent: poll.castStancesPct } }"></span>
</template>
