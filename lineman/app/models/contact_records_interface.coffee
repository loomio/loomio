angular.module('loomioApp').factory 'ContactRecordsInterface', (BaseRecordsInterface, ContactModel) ->
  class ContactRecordsInterface extends BaseRecordsInterface
    model: ContactModel

    fetchInvitables: (fragment, group) ->
      @fetch 
        params:
          group_id: group.id
          q: fragment
