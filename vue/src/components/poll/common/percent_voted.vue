<script lang="js">
export default {
  props: {
    poll: Object
  }
};
</script>

<template lang="pug">
p.text-medium-emphasis.my-2(
  v-if="poll.closingAt"
  v-t="{ path: 'poll_common_percent_voted.sentence', args: { numerator: poll.decidedVotersCount, denominator: poll.votersCount, percent: poll.castStancesPct } }"
)
</template>
