angular.module('loomioApp').factory 'ContactRecordsInterface', (BaseRecordsInterface, ContactModel) ->
  class ContactRecordsInterface extends BaseRecordsInterface
    model: ContactModel

    fetchInvitables: (invitableForm) ->
      @fetch 
        params:
          group_id: invitableForm.group.id
          q: invitableForm.fragment
