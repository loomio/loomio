BaseRecordsInterface = require 'shared/record_store/base_records_interface'
UserModel            = require 'shared/models/user_model'
RestfulClient        = require 'shared/record_store/restful_client'

module.exports = class UserRecordsInterface extends BaseRecordsInterface
  model: UserModel
  apiEndPoint: 'profile'

  onInterfaceAdded: =>
    @usersRemote = new RestfulClient('users')
    @setRemoteCallbacks(@recordStore.defaultRemoteCallbacks(), @usersRemote)

  fetchMentionable: (q) =>
    @usersRemote.fetch(path: '/', params: {q: q})

  updateProfile: (user) =>
    @remote.post 'update_profile', _.merge(user.serialize(), {unsubscribe_token: user.unsubscribeToken })

  uploadAvatar: (file) =>
    @remote.upload 'upload_avatar', file

  changePassword: (user) =>
    @remote.post 'change_password', user.serialize()

  deactivate: (user) =>
    @remote.post 'deactivate', user.serialize()

  reactivate: (user) =>
    @remote.post 'reactivate', user.serialize()

  saveExperience: (experience) =>
    @remote.post 'save_experience', experience: experience

  emailStatus: (email, token) ->
    @fetch
      path: 'email_status'
      params: _.pick {email: email, token: token}, _.identity
