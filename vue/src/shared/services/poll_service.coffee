import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import StanceService from '@/shared/services/stance_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import i18n          from '@/i18n'
import { hardReload } from '@/shared/helpers/window'
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'

export default new class PollService
  actions: (poll, vm, event) ->
    translate_poll:
      icon: 'mdi-translate'
      name: 'common.action.translate'
      dock: 2
      canPerform: -> AbilityService.canTranslate(poll)
      perform: -> Session.user() && poll.translate(Session.user().locale)

    edit_stance:
      name: 'poll_common.change_vote'
      icon: 'mdi-pencil'
      dock: 2
      canPerform: -> StanceService.canUpdateStance(poll.myStance())
      perform: -> StanceService.updateStance(poll.myStance())

    uncast_stance:
      name: 'poll_common.remove_your_vote'
      icon: 'mdi-cancel'
      menu: true
      canPerform: -> StanceService.canUpdateStance(poll.myStance())
      perform: => StanceService.uncastStance(poll.myStance())

    edit_poll:
      name: 'action_dock.edit_poll_type'
      menu: true
      nameArgs: -> {pollType: poll.translatedPollType()}
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditPoll(poll)
      to: "/p/#{poll.key}/edit"

    make_a_copy:
      icon: 'mdi-content-copy'
      name: 'templates.make_a_copy'
      menu: true
      canPerform: -> Session.user()
      to: "/p/new?template_id=#{poll.id}"

    add_poll_to_thread:
      menu: true
      name: 'action_dock.add_poll_to_thread'
      icon: 'mdi-comment-plus-outline'
      canPerform: -> AbilityService.canAddPollToThread(poll)
      perform: ->
        openModal
          component: 'AddPollToThreadModal'
          props:
            poll: poll

    announce_poll:
      icon: 'mdi-send'
      name: 'common.action.invite'
      dock: 2
      canPerform: ->
        return false if (poll.discardedAt || poll.closedAt)
        AbilityService.canAnnouncePoll(poll)
      perform: ->
        openModal
          component: 'PollMembers'
          props:
            poll: poll

    remind_poll:
      icon: 'mdi-send'
      name: 'common.action.remind'
      dock: 2
      canPerform: ->
        return false if (poll.discardedAt || poll.closedAt || poll.votersCount < 2)
        AbilityService.canAnnouncePoll(poll)
      perform: ->
        openModal
          component: 'PollReminderForm'
          props:
            poll: poll.clone()

    close_poll:
      icon: 'mdi-close-circle-outline'
      name: 'poll_common.close_early'
      dock: 2
      canPerform: ->
        AbilityService.canClosePoll(poll)
      perform: ->
        openModal
          component: 'ConfirmModal',
          props:
            confirm:
              submit: -> poll.close()
              successCallback: ->
                openModal
                  component: 'PollCommonOutcomeModal'
                  props:
                    outcome: Records.outcomes.build
                      groupId: poll.groupId
                      pollId: poll.id
                      statementFormat: Session.defaultFormat()
              text:
                title: 'poll_common_close_form.title'
                helptext: 'poll_common_close_form.helptext'
                flash: 'poll_common_close_form.poll_type_closed'
              textArgs:
                poll_type: poll.translatedPollType()

    reopen_poll:
      icon: 'mdi-refresh'
      name: 'common.action.reopen'
      dock: 3
      canPerform: ->
        AbilityService.canReopenPoll(poll)
      perform: ->
        openModal
          component: 'PollCommonReopenModal'
          props: { poll: poll }

    add_comment:
      name: 'activity_card.add_comment'
      icon: 'mdi-reply'
      dock: 1
      canPerform: -> !poll.discardedAt && poll.discussionId && AbilityService.canAddComment(poll.discussion()) && !poll.closingAt
      perform: ->
        EventBus.$emit('toggle-reply', poll, event.id)

    show_history:
      icon: 'mdi-history'
      name: 'action_dock.show_edits'
      menu: true
      canPerform: -> !poll.discardedAt && poll.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: poll

    notification_history:
      name: 'action_dock.notification_history'
      icon: 'mdi-alarm-check'
      menu: true
      perform: ->
        openModal
          component: 'AnnouncementHistory'
          props:
            model: poll
      canPerform: -> !poll.discardedAt

    move_poll:
      name: 'common.action.move'
      icon: 'mdi-folder-swap-outline'
      menu: true
      canPerform: ->
        AbilityService.canMovePoll(poll)
      perform: ->
        openModal
          component: 'PollCommonMoveForm'
          props:
            poll: poll.clone()

    export_poll:
      name: 'common.action.export'
      icon: 'mdi-database-arrow-right-outline'
      menu: true
      canPerform: ->
        AbilityService.canExportPoll(poll)
      perform: ->
        hardReload LmoUrlService.poll(poll, {export: 1}, {action: 'export', ext: 'csv', absolute: true})

    print_poll:
      name: 'common.action.print'
      icon: 'mdi-printer-outline'
      menu: true
      canPerform: ->
        AbilityService.canExportPoll(poll)
      perform: ->
        hardReload LmoUrlService.poll(poll, {export: 1}, {action: 'export', ext: 'html', absolute: true})

    # delete_poll:
    #   name: 'common.action.delete'
    #   canPerform: ->
    #     AbilityService.canDeletePoll(poll)
    #   perform: ->
    #     openModal
    #       component: 'ConfirmModal'
    #       props:
    #         confirm:
    #           submit: -> poll.destroy()
    #           text:
    #             title: 'poll_common_delete_modal.title'
    #             confirm: 'poll_common_delete_modal.question'
    #             flash: 'poll_common_delete_modal.success'

    discard_poll:
      name: 'poll_common.delete_poll'
      menu: true
      icon: 'mdi-delete'
      canPerform: ->
        AbilityService.canDeletePoll(poll)
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: -> poll.discard()
              text:
                raw_title: i18n.t('poll_common_delete_modal.title', pollType: i18n.t(poll.pollTypeKey()))
                helptext: 'poll_common_delete_modal.question'
                flash: 'poll_common_delete_modal.success'

