import openModal from '@/shared/helpers/open_modal'
import AbilityService from '@/shared/services/ability_service'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'

export default new class OutcomeService
  actions: (outcome, vm) ->
    poll = outcome.poll()

    react:
      canPerform: -> AbilityService.canReactToPoll(poll)

    # notification_history:
    #   name: 'action_dock.notification_history'
    #   icon: 'mdi-alarm-check'
    #   perform: ->
    #     openModal
    #       component: 'AnnouncementHistory'
    #       props:
    #         model: outcome
    #   canPerform: -> true

    announce_outcome:
      icon: 'mdi-send'
      name: 'action_dock.notify'
      active: -> outcome.announcementsCount == 0
      canPerform: -> AbilityService.canSetPollOutcome(poll)
      perform: ->
        openModal
          component: 'AnnouncementForm'
          props:
            announcement: Records.announcements.buildFromModel(outcome)

    edit_outcome:
      name: 'common.action.edit'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canSetPollOutcome(poll)
      perform: ->
        openModal
          component: 'PollCommonOutcomeModal',
          props:
            outcome: outcome

    translate_outcome:
      name: 'common.action.translate'
      icon: 'mdi-translate'
      canPerform: ->
        AbilityService.canTranslate(outcome)
      perform: ->
        Session.user() && outcome.translate(Session.user().locale)
