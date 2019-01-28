<style lang="scss">
</style>

<script lang="coffee">
AbilityService = require 'shared/services/ability_service'

module.exports =
  props:
    discussion: Object
  methods:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)
</script>

<template lang="pug">

v-card.decision-tools-card.lmo-no-print(v-if='canStartPoll()')
  v-subheader(v-t="'decision_tools_card.title'")
  poll-common-start-form(:discussion='discussion')

</template>
