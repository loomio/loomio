import openModal from '@/shared/helpers/open_modal'
import AbilityService from '@/shared/services/ability_service'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'

export default new class OutcomeService
  actions: (outcome) ->
    poll = outcome.poll()
    user = Session.user()

    translate_outcome:
      name: 'common.action.translate'
      icon: 'mdi-translate'
      dock: 2
      canPerform: ->
        AbilityService.canTranslate(outcome)
      perform: ->
        Session.user() && outcome.translate(user.locale)

    react:
      dock: 1
      canPerform: -> poll.membersInclude(user)

    edit_outcome:
      name: 'common.action.edit'
      icon: 'mdi-pencil'
      dock: 1
      canPerform: -> AbilityService.canSetPollOutcome(poll)
      perform: ->
        openModal
          component: 'PollCommonOutcomeModal',
          props:
            outcome: outcome.clone()

    show_history:
      icon: 'mdi-history'
      name: 'action_dock.show_edits'
      dock: 1
      canPerform: -> outcome.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: outcome

    notification_history:
      name: 'action_dock.show_notifications'
      icon: 'mdi-alarm-check'
      menu: true
      perform: ->
        openModal
          component: 'AnnouncementHistory'
          props:
            model: outcome
      canPerform: -> true
