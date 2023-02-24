import AppConfig        from '@/shared/services/app_config'
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'

export default new class StanceService
  actions: (stance, vm, event) ->
    react:
      dock: 1
      canPerform: ->
        !stance.discardedAt && stance.castAt &&
        stance.poll().membersInclude(Session.user())

    edit_stance:
      name: 'poll_common.change_vote'
      icon: 'mdi-pencil'
      dock: 1
      canPerform: => @canUpdateStance(stance)
      perform: => @updateStance(stance)

    add_comment:
      name: 'common.action.reply'
      icon: 'mdi-reply'
      dock: 1
      canPerform: -> 
        !stance.poll().anonymous &&
        AbilityService.canAddComment(stance.poll().discussion())
      perform: ->
        if event.depth == stance.discussion().maxDepth
          EventBus.$emit('toggle-reply', stance, event.parentId)
        else
          EventBus.$emit('toggle-reply', stance, event.id)

    uncast_stance:
      name: 'poll_common.remove_your_vote'
      icon: 'mdi-cancel'
      dock: 1
      canPerform: => @canUpdateStance(stance)
      perform: => @uncastStance(stance)

    translate_stance:
      icon: 'mdi-translate'
      name: 'common.action.translate'
      dock: 2
      canPerform: ->
        (stance.author() && Session.user()) &&
        stance.author().locale != Session.user().locale &&
        AbilityService.canTranslate(stance)
      perform: ->
        stance.translate(Session.user().locale)

    show_history:
      name: 'action_dock.edited'
      icon: 'mdi-history'
      dock: 1
      canPerform: -> stance.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: stance

  updateStance: (stance) ->
    openModal
      component: 'PollCommonEditVoteModal',
      props:
        stance: stance.clone()
        
  uncastStance: (stance) ->
    openModal
      component: 'ConfirmModal',
      props:
        confirm:
          submit: ->
            Records.remote.patch("stances/#{stance.id}/uncast")
          text:
            title: 'poll_remove_vote.title'
            helptext: 'poll_remove_vote.helptext'
            submit: 'poll_remove_vote.confirm'
            flash: 'poll_remove_vote.success'

  canUpdateStance: (stance) ->
    stance &&
    stance.latest &&
    stance.poll().myStanceId == stance.id &&
    stance.poll().isVotable() && 
    stance.poll().iHaveVoted()

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
      Records.remote.post('stances/remove_admin', participant_id: user.id, poll_id: poll.id, exclude_types: 'discussion')

  revoke:
    name: 'membership_dropdown.remove_from.poll'
    canPerform: (poll, user) ->
      poll.adminsInclude(Session.user())
    perform: (poll, user) ->
      Records.remote.post 'stances/revoke', {participant_id: user.id, poll_id: poll.id}
      .then =>
        if user.id == Session.user().id
          EventBus.$emit('deleteMyStance', poll.id) 
        Flash.success "membership_remove_modal.invitation.flash"
