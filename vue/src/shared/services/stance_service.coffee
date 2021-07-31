import AppConfig        from '@/shared/services/app_config'
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'

export default new class StanceService
  actions: (stance) ->
    react:
      canPerform: ->
        !stance.discardedAt &&
        AppConfig.features.app.vote_reactions &&
        stance.poll().membersInclude(Session.user())
        
    edit_stance:
      name: 'poll_common.change_vote'
      icon: 'mdi-pencil'
      canPerform: ->
        (Session.user() && stance.participant()) &&
        stance.latest && stance.poll().isActive() && stance.participant() == Session.user()
      perform: =>
        openModal
          component: 'PollCommonEditVoteModal',
          props:
            stance: stance.clone()

    translate_stance:
      icon: 'mdi-translate'
      name: 'common.action.translate'
      canPerform: ->
        (stance.author() && Session.user()) &&
        stance.author().locale != Session.user().locale &&
        AbilityService.canTranslate(stance)
      perform: ->
        stance.translate(Session.user().locale)

    show_history:
      name: 'action_dock.edited'
      icon: 'mdi-history'
      canPerform: -> stance.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: stance
  makeAdmin:
    name: 'membership_dropdown.make_coordinator'
    canPerform: (poll, user) ->
      poll.adminsInclude(Session.user()) && !poll.adminsInclude(user)
    perform: (poll, user) ->
      Records.remote.post 'stances/make_admin', participant_id: user.id, poll_id: poll.id, exclude_types: 'discussion'

  removeAdmin:
    name: 'membership_dropdown.demote_coordinator'
    canPerform: (poll, user) ->
      poll.adminsInclude(Session.user()) && poll.adminsInclude(user)
    perform: (poll, user) ->
      Records.remote.post 'stances/remove_admin', participant_id: user.id, poll_id: poll.id, exclude_types: 'discussion'

  revoke:
    name: 'membership_dropdown.remove_from.poll'
    canPerform: (poll, user) ->
      poll.adminsInclude(Session.user())
    perform: (poll, user) ->
      Records.remote.post 'stances/revoke', {participant_id: user.id, poll_id: poll.id}
      .then ->
        Flash.success "membership_remove_modal.invitation.flash"
