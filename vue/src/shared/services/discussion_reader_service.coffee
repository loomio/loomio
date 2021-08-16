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
      !dr.discussion().group().adminsInclude(dr.user()) &&
      !dr.admin && dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      Records.discussionReaders.remote.postMember dr.id, 'make_admin', exclude_types: 'discussion'
      .then (data) => Records.importJSON(data)

  removeAdmin:
    name: 'membership_dropdown.demote_coordinator'
    canPerform: (dr) ->
      dr.admin && dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      Records.discussionReaders.remote.postMember dr.id, 'remove_admin', exclude_types: 'discussion'
      .then (data) => Records.importJSON(data)

  resend:
    name: 'membership_dropdown.resend'
    canPerform: (dr) ->
      dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      Records.discussionReaders.remote.postMember dr.id, 'resend', exclude_types: 'discussion'
      .then (data) => Records.importJSON(data)
      .then ->
        Flash.success "membership_dropdown.invitation_resent"

  revoke:
    name: 'membership_dropdown.remove_from.discussion'
    canPerform: (dr) ->
      dr.discussion().adminsInclude(Session.user())
    perform: (dr) ->
      Records.discussionReaders.remote.postMember dr.id, 'revoke'
      .then (data) => Records.importJSON(data)
      .then ->
        Flash.success "membership_remove_modal.invitation.flash"
