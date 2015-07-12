angular.module('loomioApp').factory 'UserRecordsInterface', (BaseRecordsInterface, UserModel, RestfulClient) ->
  class UserRecordsInterface extends BaseRecordsInterface
    model: UserModel

    constructor: (recordStore) ->
      @baseConstructor recordStore
      @profileClient = new RestfulClient 'profile'

    updateProfile: (user) ->
      @profileClient.post 'update_profile', user.serialize()

    uploadAvatar: (file) ->
      @profileClient.upload 'upload_avatar', file

    changePassword: (user) ->
      @profileClient.post 'change_password', user.serialize()

    deactivate: (user) ->
      @profileClient.post 'deactivate', user.serialize()
