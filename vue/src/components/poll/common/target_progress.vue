<script lang="coffee">
export default
  props:
    poll: Object

  computed:
    agreeResult: -> @poll.results.find (r) -> r.icon == 'agree'
    agreeCount: -> @agreeResult.voter_count
    targetPercent: -> @agreeResult.target_percent
</script>

<template lang="pug">

p.text--secondary.my-2(v-if="poll.closingAt")
  span(
    v-t="{path: 'poll_common_percent_voted.target_progress', args: { num: agreeCount, target: poll.agreeTarget, percent: targetPercent } }"
  )
</template>
