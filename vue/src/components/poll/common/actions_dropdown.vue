<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [PollModalMixin]
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
      @openEditPollModal(@poll)

    closePoll: ->
      @openClosePollModal(@poll)

    reopenPoll: ->
      ModalService.open 'PollCommonReopenModal', poll: => @poll

    deletePoll: ->
      ModalService.open 'PollCommonDeleteModal', poll: => @poll

    toggleSubscription: ->
      ModalService.open 'PollCommonUnsubscribeModal', poll: => @poll
</script>

<template lang="pug">
v-menu.poll-actions-dropdown
  v-btn.poll-actions-dropdown__button(flat icon slot="activator")
    .sr-only(v-t="'group_page.options_label'")
    v-icon mdi-chevron-down
  v-list
    v-list-tile.poll-actions-dropdown__subscribe(@click="toggleSubscription()")
      span(v-t="'common.action.unsubscribe'", v-if="poll.subscribed")
      span(v-t="'common.action.subscribe'", v-if="!poll.subscribed")
    v-list-tile.poll-actions-dropdown__edit(v-if="canEditPoll()", @click="editPoll()")
      span(v-t="'common.action.edit'")
    v-list-tile.poll-actions-dropdown__close(v-if="canClosePoll()", @click="closePoll()")
      span(v-t="{ path: 'poll_common.close_poll_type', args: { 'poll-type': $t(poll.pollTypeKey()) } }")
    v-list-tile.poll-actions-dropdown__reopen(v-if="canReopenPoll()", @click="reopenPoll()")
      span(v-t="'common.action.reopen'")
    v-list-tile.poll-actions-dropdown__export(v-if="canExportPoll()", @click="exportPoll()")
      span(v-t="'common.action.export'")
    v-list-tile.poll-actions-dropdown__delete(v-if="canDeletePoll()", @click="deletePoll()")
      span(v-t="'common.action.delete'")
</template>
