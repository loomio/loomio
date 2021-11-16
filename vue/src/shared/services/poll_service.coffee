import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import i18n          from '@/i18n'
import { hardReload } from '@/shared/helpers/window'

export default new class PollService
  actions: (poll) ->
    translate_poll:
      icon: 'mdi-translate'
      name: 'common.action.translate'
      dock: 2
      canPerform: ->
        AbilityService.canTranslate(poll)
      perform: -> Session.user() && poll.translate(Session.user().locale)

    show_results:
      icon: 'mdi-eye-outline'
      name: 'poll_common_card.show_results'
      dock: 2
      canPerform: ->
        !poll.discardedAt && poll.closingAt && !poll.hideResultsUntilClosed && !poll.showResults()
      perform: ->
        poll.pleaseShowResults = true

    hide_results:
      icon: 'mdi-eye-off-outline'
      name: 'poll_common_card.hide_results'
      dock: 2
      canPerform: ->
        !poll.discardedAt && poll.showResults() && !poll.closedAt && !poll.iHaveVoted()
      perform: ->
        poll.pleaseShowResults = false

    edit_stance:
      name: 'poll_common.change_vote'
      icon: 'mdi-pencil'
      dock: 2
      canPerform: =>
        poll.isActive() && Session.user() && poll.iHaveVoted()
      perform: =>
        openModal
          component: 'PollCommonEditVoteModal',
          maxWidth: 720
          props:
            stance: poll.myStance().clone()

    announce_poll:
      icon: 'mdi-send'
      name: 'common.action.invite'
      dock: 2
      canPerform: ->
        return false if (poll.discardedAt || poll.closedAt)
        poll.adminsInclude(Session.user()) ||
        (!poll.specifiedVotersOnly &&
         (poll.group().membersCanAddGuests || poll.group().membersCanAnnounce) &&
         poll.membersInclude(Session.user()))
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
        poll.adminsInclude(Session.user()) ||
        (!poll.specifiedVotersOnly &&
         (poll.group().membersCanAddGuests || poll.group().membersCanAnnounce) &&
         poll.membersInclude(Session.user()))
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
                confirm: 'poll_common_close_form.close_poll'
                flash: 'poll_common_close_form.poll_closed'
                params:
                  poll_type: poll.translatedPollType()

    reopen_poll:
      icon: 'mdi-refresh'
      name: 'common.action.reopen'
      dock: 2
      canPerform: ->
        AbilityService.canReopenPoll(poll)
      perform: ->
        openModal
          component: 'PollCommonReopenModal'
          props: { poll: poll }

    edit_poll:
      name: 'action_dock.edit_poll_type'
      dock: 1
      nameArgs: ->
        {pollType: poll.translatedPollType()}
      icon: 'mdi-pencil'
      canPerform: ->
        AbilityService.canEditPoll(poll)
      to: "/p/#{poll.key}/edit"
      # perform: ->
      #   openModal
      #     component: 'PollCommonModal'
      #     props:
      #       poll: poll.clone()

    show_history:
      icon: 'mdi-history'
      name: 'action_dock.show_edits'
      dock: 1
      canPerform: -> !poll.discardedAt && poll.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: poll

    notification_history:
      name: 'action_dock.show_notifications'
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

    add_poll_to_thread:
      menu: true
      name: 'action_dock.add_poll_to_thread'
      icon: 'mdi-comment-plus-outline'
      canPerform: ->
        AbilityService.canAddPollToThread(poll)
      perform: ->
        openModal
          component: 'AddPollToThreadModal'
          props:
            poll: poll

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

    discard_poll:
      name: 'common.action.discard'
      menu: true
      icon: 'mdi-delete'
      canPerform: -> AbilityService.canDiscardPoll(poll)
      perform: -> poll.discard()

    # undiscard_poll:
    #   name: 'common.action.restore'
    #   menu: true
    #   icon: 'mdi-delete-restore'
    #   canPerform: -> AbilityService.canUndiscardPoll(poll)
    #   perform: -> poll.undiscard()
    #
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
    #             helptext: 'poll_common_delete_modal.body'
    #             submit: 'common.action.delete'
    #             flash: 'poll_common_delete_modal.success'
    #             params:
    #               pollType: poll.translatedPollType()
