<script lang="coffee">
export default
  props:
    poll: Object

  data: ->
    pollTypes: [
      {text: "Single choice", value: "single_choice"}
      {text: "Multiple choice", value: "single_choice"}
      {text: "Score", value: "score"}
      {text: "Allocate", value: "dot_vote"}
      {text: "Rank", value: "ranked_choice"}
      {text: "Availability", value: "meeting"}
    ]


</script>
<template lang="pug">
.poll-common-form
  v-select(v-model="poll.pollType" :items="pollTypes" label="Voting method")
  poll-common-form-fields(:poll="poll")
  poll-common-form-options-field(:poll="poll")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
  common-notify-fields(:model="poll")
</template>
