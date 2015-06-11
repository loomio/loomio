angular.module('loomioApp').factory 'UserRecordsInterface', (BaseRecordsInterface, UserModel) ->
  class UserRecordsInterface extends BaseRecordsInterface
    model: UserModel

    fetchInvitables: (fragment, group) ->
      @fetch 
        params:
          group_id: group.id
          q: fragment