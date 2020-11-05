import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'

export default new class StanceService
  makeAdmin:
    name: 'membership_dropdown.make_coordinator'
    canPerform: (stance) ->
      !stance.poll().group().adminsInclude(stance.participant()) &&
      !stance.admin && stance.poll().adminsInclude(Session.user())
    perform: (stance) ->
      Records.stances.remote.postMember stance.id, 'make_admin', exclude_types: 'discussion'

  removeAdmin:
    name: 'membership_dropdown.demote_coordinator'
    canPerform: (stance) ->
      stance.admin && stance.poll().adminsInclude(Session.user())
    perform: (stance) ->
      Records.stances.remote.postMember stance.id, 'remove_admin', exclude_types: 'discussion'

  resend:
    name: 'membership_dropdown.resend'
    canPerform: (stance) ->
      stance.poll().adminsInclude(Session.user())
    perform: (stance) ->
      Records.stances.remote.postMember stance.id, 'resend', exclude_types: 'discussion'
      .then ->
        Flash.success "membership_dropdown.invitation_resent"

  revoke:
    name: 'membership_dropdown.remove_from.poll'
    canPerform: (stance) ->
      stance.poll().adminsInclude(Session.user())
    perform: (stance) ->
      Records.stances.remote.postMember stance.id, 'revoke'
      .then ->
        Flash.success "membership_remove_modal.invitation.flash"
