angular.module('loomioApp').factory 'UserRecordsInterface', (BaseRecordsInterface, UserModel) ->
  class UserRecordsInterface extends BaseRecordsInterface
    model: UserModel

    updateProfile: (user) ->
      @restfulClient.post 'update_profile', user.serialize()

    changePassword: (user) ->
      @restfulClient.post 'change_password', user.serialize()

    deactivate: (user) ->
      @restfulClient.post 'deactivate', user.serialize()
