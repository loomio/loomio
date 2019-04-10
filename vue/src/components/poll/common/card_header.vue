<script lang="coffee">
AbilityService = require 'shared/services/ability_service'

{ iconFor } = require 'shared/helpers/poll'

module.exports =
  props:
    poll: Object
  methods:
    pollHasActions: ->
      AbilityService.canEditPoll(@poll)  ||
      AbilityService.canClosePoll(@poll) ||
      AbilityService.canDeletePoll(@poll)||
      AbilityService.canExportPoll(@poll)

    icon: ->
      iconFor(@poll)
</script>

<template lang="pug">
v-layout.poll-common-card-header
  v-icon {{'mdi ' + icon()}}
  v-subheader(v-t="'poll_types.' + poll.pollType")
  v-spacer
  poll-common-actions-dropdown(:poll="poll", v-if="pollHasActions()")
</template>
