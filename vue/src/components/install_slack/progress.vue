<script lang="coffee">
export default
  props:
    slackProgress: Number
  methods:
    progressPercent: -> "#{@slackProgress}%"
</script>
<template lang="pug">
.install-slack-progress
  .install-slack-progress__bar
  .install-slack-progress__bar.active(:style="{'width': progressPercent()}")
  .install-slack-progress__dot(:class="{'active': slackProgress == 0, 'complete': slackProgress >= 0}")
    label(v-t="'install_slack.progress.install'")
  .install-slack-progress__dot(:class="{'active': slackProgress == 50, 'complete': slackProgress >= 50}")
    label(v-t="'install_slack.progress.invite'")
  .install-slack-progress__dot(:class="{'active': slackProgress == 100, 'complete': slackProgress >= 100}")
    label(v-t="'install_slack.progress.decide'")
</template>
