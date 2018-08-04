BaseRecordsInterface = require 'shared/record_store/base_records_interface'
UserModel            = require 'shared/models/user_model'

module.exports = class UserRecordsInterface extends BaseRecordsInterface
  model: UserModel
  apiEndPoint: 'profile'

  fetchMentionable: (q) =>
    @fetch
      path: 'mentionable_users'
      params: {q: q}

  updateProfile: (user) =>
    @remote.post 'update_profile', _.merge(user.serialize(), {unsubscribe_token: user.unsubscribeToken })

  uploadAvatar: (file) =>
    @remote.upload 'upload_avatar', file

  changePassword: (user) =>
    @remote.post 'change_password', user.serialize()

  deactivate: (user) =>
    @remote.post 'deactivate', user.serialize()

  destroy: => @remote.delete '/'

  reactivate: (user) =>
    @remote.post 'reactivate', user.serialize()

  saveExperience: (experience) =>
    @remote.post 'save_experience', experience: experience

  emailStatus: (email, token) ->
    @fetch
      path: 'email_status'
      params: _.pick {email: email, token: token}, _.identity
