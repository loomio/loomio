angular.module('loomioApp').factory 'UserRecordsInterface', (BaseRecordsInterface, UserModel) ->
  class UserRecordsInterface extends BaseRecordsInterface
    model: UserModel

    updateProfile: (user) ->
      @restfulClient.post 'update_profile', user.serialize()