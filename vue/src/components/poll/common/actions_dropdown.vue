<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import PollModalMixin from '@/mixins/poll_modal'
import ConfirmModalMixin from '@/mixins/confirm_modal'
import Records           from '@/shared/services/records'

export default
  mixins: [PollModalMixin, ConfirmModalMixin]
  props:
    poll: Object

  computed:
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

  methods:
    exportPoll: ->
      # exportPath = LmoUrlService.poll(@poll, {}, action:'export', absolute:true)
      # LmoUrlService.goTo(exportPath,true)

    sharePoll: ->
      ModalService.open 'PollCommonShareModal', poll: => @poll

    editPoll: ->
      @openEditPollModal(@poll)

    closePoll: ->
      @openConfirmModal
        submit: => @poll.close()
        successCallback: =>
          outcome = Records.outcomes.build(pollId: @poll.id)
          @openPollOutcomeModal(outcome)
        text:
          title:    'poll_common_close_form.title'
          helptext: 'poll_common_close_form.helptext'
          confirm:  'poll_common_close_form.close_poll'
          flash:    'poll_common_close_form.poll_closed'

    reopenPoll: ->
      @openReopenPollModal(@poll)

    deletePoll: ->
      ModalService.open 'PollCommonDeleteModal', poll: => @poll

</script>

<template lang="pug">
v-menu.poll-actions-dropdown(lazy)
  v-btn.poll-actions-dropdown__button(text icon slot="activator")
    .sr-only(v-t="'group_page.options_label'")
    v-icon mdi-chevron-down
  v-list
    v-list-item.poll-actions-dropdown__edit(v-if="canEditPoll", @click="editPoll()")
      span(v-t="'common.action.edit'")
    v-list-item.poll-actions-dropdown__close(v-if="canClosePoll", @click="closePoll()")
      span(v-t="{ path: 'poll_common.close_poll_type', args: { 'poll-type': $t(poll.pollTypeKey()) } }")
    v-list-item.poll-actions-dropdown__reopen(v-if="canReopenPoll", @click="reopenPoll()")
      span(v-t="'common.action.reopen'")
    v-list-item.poll-actions-dropdown__export(v-if="canExportPoll", @click="exportPoll()")
      span(v-t="'common.action.export'")
    v-list-item.poll-actions-dropdown__delete(v-if="canDeletePoll", @click="deletePoll()")
      span(v-t="'common.action.delete'")
</template>
