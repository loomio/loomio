angular.module('loomioApp').factory 'UserRecordsInterface', (BaseRecordsInterface, UserModel) ->
  class UserRecordsInterface extends BaseRecordsInterface
    model: UserModel

    fetchInvitables: (invitableForm) ->
      @fetch
        path: '/invitables'
        params:
          group_id: invitableForm.group.id
          q: invitableForm.fragment