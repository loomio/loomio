angular.module('loomioApp').factory 'UserRecordsInterface', (BaseRecordsInterface, UserModel) ->
  class UserRecordsInterface extends BaseRecordsInterface
    model: UserModel

    deactivate: (user) ->
      @restfulClient.post 'deactivate', user.serialize()

    updateProfile: (user) ->
      @restfulClient.post 'update_profile', user.serialize()