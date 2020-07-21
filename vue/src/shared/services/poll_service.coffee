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
  actions: (poll, vm) ->
    edit_stance:
      name: 'poll_common.change_vote'
      icon: 'mdi-pencil'
      canPerform: =>
        poll.isActive() && Session.user() && poll.myStance() && poll.myStance().castAt
      perform: =>
        openModal
          component: 'PollCommonEditVoteModal',
          props:
            stance: poll.myStance().clone()

    notification_history:
      name: 'action_dock.notification_history'
      icon: 'mdi-alarm-check'
      perform: ->
        openModal
          component: 'AnnouncementHistory'
          props:
            model: poll
      canPerform: -> true

    announce_poll:
      icon: 'mdi-send'
      canPerform: ->
        AbilityService.canAnnounceTo(poll)
      perform: ->
        openModal
          component: 'AnnouncementForm'
          props:
            announcement: Records.announcements.buildFromModel(poll)

    edit_poll:
      name: 'common.action.edit'
      icon: 'mdi-pencil'
      canPerform: ->
        AbilityService.canEditPoll(poll)
      perform: ->
        openModal
          component: 'PollCommonModal'
          props:
            poll: poll.clone()

    move_poll:
      name: 'common.action.move'
      icon: 'mdi-folder-swap-outline'
      canPerform: ->
        AbilityService.canMovePoll(poll)
      perform: ->
        openModal
          component: 'PollCommonMoveForm'
          props:
            poll: poll.clone()

    show_history:
      icon: 'mdi-history'
      name: 'action_dock.edited'
      canPerform: -> poll.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: poll

    translate_poll:
      icon: 'mdi-translate'
      menu: true
      canPerform: ->
        AbilityService.canTranslate(poll)
      perform: -> Session.user() && poll.translate(Session.user().locale)

    close_poll:
      icon: 'mdi-close-circle-outline'
      name:
        path: 'poll_common.close_poll_type'
        args: {'poll-type': vm.$t(poll.pollTypeKey())}
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
                      pollId: poll.id
                      statementFormat: Session.defaultFormat()
              text:
                title: 'poll_common_close_form.title'
                raw_helptext: i18n.t('poll_common_close_form.helptext', poll_type: i18n.t(poll.pollTypeKey()))
                confirm: 'poll_common_close_form.close_poll'
                flash: 'poll_common_close_form.poll_closed'

    reopen_poll:
      icon: 'mdi-refresh'
      name: 'common.action.reopen'
      canPerform: ->
        AbilityService.canReopenPoll(poll)
      perform: ->
        openModal
          component: 'PollCommonReopenModal'
          props: { poll: poll }

    export_poll:
      name: 'common.action.export'
      canPerform: ->
        AbilityService.canExportPoll(poll)
      perform: ->
        hardReload LmoUrlService.poll(poll, {export: 1}, {action: 'export', ext: 'csv', absolute: true})

    print_poll:
      name: 'common.action.print'
      canPerform: ->
        AbilityService.canExportPoll(poll)
      perform: ->
        hardReload LmoUrlService.poll(poll, {export: 1}, {action: 'export', ext: 'html', absolute: true})

    delete_poll:
      name: 'common.action.delete'
      canPerform: ->
        AbilityService.canDeletePoll(poll)
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: -> poll.destroy()
              text:
                title: 'poll_common_delete_modal.title'
                confirm: 'poll_common_delete_modal.question'
                flash: 'poll_common_delete_modal.success'

    discard_poll:
      name: 'common.action.delete'
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
