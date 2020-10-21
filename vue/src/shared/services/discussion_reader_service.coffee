import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'

export default new class DiscussionReaderService
  makeAdmin:
    name: 'membership_dropdown.make_coordinator'
    canPerform: (dr) ->
      !dr.admin && dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      Records.discussionReaders.remote.postMember dr.id, 'make_admin'

  removeAdmin:
    name: 'membership_dropdown.demote_coordinator'
    canPerform: (dr) ->
      dr.admin && dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      Records.discussionReaders.remote.postMember dr.id, 'remove_admin'

  resend:
    name: 'membership_dropdown.resend'
    canPerform: (dr) ->
      dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      Records.discussionReaders.remote.postMember dr.id, 'resend'
      .then ->
        Flash.success "membership_dropdown.invitation_resent"

  remove:
    name: 'membership_dropdown.remove_from.discussion'
    canPerform: (dr) ->
      dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      dr.destroy()
      .then ->
        Flash.success "membership_remove_modal.invitation.flash"
