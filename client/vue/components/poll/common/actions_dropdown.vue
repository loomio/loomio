<script lang="coffee">
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

module.exports =
  props:
    poll: Object
  methods:
    canEditPoll: ->
      AbilityService.canEditPoll(@poll)

    canClosePoll: ->
      AbilityService.canClosePoll(@poll)

    canReopenPoll: ->
      AbilityService.canReopenPoll(@poll)

    canExportPoll: ->
      AbilityService.canExportPoll(@poll)

    canDeletePoll: ->
      AbilityService.canDeletePoll(@poll)

    exportPoll: ->
      # exportPath = LmoUrlService.poll(@poll, {}, action:'export', absolute:true)
      # LmoUrlService.goTo(exportPath,true)

    sharePoll: ->
      ModalService.open 'PollCommonShareModal', poll: => @poll

    editPoll: ->
      ModalService.open 'PollCommonEditModal', poll: => @poll

    closePoll: ->
      ModalService.open 'PollCommonCloseModal', poll: => @poll

    reopenPoll: ->
      ModalService.open 'PollCommonReopenModal', poll: => @poll

    deletePoll: ->
      ModalService.open 'PollCommonDeleteModal', poll: => @poll

    toggleSubscription: ->
      ModalService.open 'PollCommonUnsubscribeModal', poll: => @poll
</script>

<template lang="pug">
v-menu
  v-btn(slot="activator")
    .sr-only(v-t="'group_page.options_label'")
    v-icon mdi-chevron-down
  v-list
    v-list-tile(@click="toggleSubscription()")
      span(v-t="'common.action.unsubscribe'", v-if="poll.subscribed")
      span(v-t="'common.action.subscribe'", v-if="!poll.subscribed")
    v-list-tile(v-if="canEditPoll()", @click="editPoll()")
      span(v-t="'common.action.edit'")
    v-list-tile(v-if="canClosePoll()", @click="closePoll()")
      span(v-t="{ path: 'poll_common.close_poll_type', args: { 'poll-type': poll.translatedPollType() }")
    v-list-tile(v-if="canReopenPoll()", @click="reopenPoll()")
      span(v-t="common.action.reopen")
    v-list-tile(v-if="canExportPoll()", @click="exportPoll()")
      span(v-t="common.action.export")
    v-list-tile(v-if="canDeletePoll()", @click="deletePoll()")
      span(v-t="common.action.delete")
</template>
