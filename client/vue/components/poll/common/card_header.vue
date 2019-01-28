<style lang="scss">
.poll-common-card-header__poll-type {
  margin-left: 10px;
  line-height: 25px;
}
</style>

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
  //- .poll-common-card-header.lmo-flex
  //-   i.mdi-24px(class="'mdi ' + icon()")
  //-   h2.lmo-card-heading.poll-common-card-header__poll-type
  //- // <poll_common_actions_dropdown poll="poll" ng-if="pollHasActions()" class="pull-right"></poll_common_actions_dropdown>
</template>
