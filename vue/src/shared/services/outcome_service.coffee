import openModal from '@/shared/helpers/open_modal'
import AbilityService from '@/shared/services/ability_service'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'

export default new class OutcomeService
  actions: (outcome, vm) ->
    poll = outcome.poll()

    react:
      canPerform: -> AbilityService.canReactToPoll(poll)

    announce_outcome:
      icon: 'mdi-send'
      active: -> outcome.announcementsCount == 0
      canPerform: -> AbilityService.canSetPollOutcome(poll)
      perform: ->
        openModal
          component: 'AnnouncementForm'
          props:
            announcement: Records.announcements.buildFromModel(outcome)

    edit_outcome:
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canSetPollOutcome(poll)
      perform: ->
        openModal
          component: 'PollCommonOutcomeModal',
          props:
            outcome: outcome

    translate_outcome:
      icon: 'mdi-translate'
      canPerform: ->
        AbilityService.canTranslate(outcome)
      perform: ->
        outcome.translate(Session.user().locale)
