angular.module('loomioApp').factory 'UserRecordsInterface', (BaseRecordsInterface, UserModel, RestfulClient) ->
  class UserRecordsInterface extends BaseRecordsInterface
    model: UserModel

    updateProfile: (user) =>
      @remote.post 'update_profile', user.serialize()

    uploadAvatar: (file) =>
      @remote.upload 'upload_avatar', file

    changePassword: (user) =>
      @remote.post 'change_password', user.serialize()

    deactivate: (user) =>
      @remote.post 'deactivate', user.serialize()
