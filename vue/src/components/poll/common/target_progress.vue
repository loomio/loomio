<script lang="js">
export default {
  props: {
    poll: Object
  },

  computed: {
    agreeResult() { return this.poll.results.find(r => r.icon === 'agree'); },
    agreeCount() { return this.agreeResult.voter_count; },
    targetPercent() { return this.agreeResult.target_percent; }
  }
};
</script>

<template lang="pug">

p.text--secondary.my-2(v-if="poll.closingAt")
  span(
    v-t="{path: 'poll_common_percent_voted.target_progress', args: { num: agreeCount, target: poll.agreeTarget, percent: targetPercent } }"
  )
</template>
