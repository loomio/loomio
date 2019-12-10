import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import UserModel            from '@/shared/models/user_model'
import {map, includes} from 'lodash'

export default class UserRecordsInterface extends BaseRecordsInterface
  model: UserModel
  apiEndPoint: 'profile'

  fetchTimeZones: ->
    @remote.fetch path: "time_zones"

  fetchGroups: ->
    @remote.fetch path: "groups"

  fetchMentionable: (q, model) =>
    model = model.discussion() if !model.id? && model.discussionId
    model = model.group() if !model.id? && !model.discussionId
    @fetch
      path: 'mentionable_users'
      params:
        q: q
        "#{model.constructor.singular}_id": model.id

  updateProfile: (user) =>
    user.processing = true
    @remote.post('update_profile', _.merge(user.serialize(), {unsubscribe_token: user.unsubscribeToken }))

  uploadAvatar: (file) =>
    @remote.upload 'upload_avatar', file

  changePassword: (user) =>
    user.processing = true
    @remote.post('change_password', user.serialize()).finally ->
      user.processing = false

  deactivate: (user) =>
    user.processing = true
    @remote.post('deactivate', user.serialize()).finally -> user.processing = false

  destroy: => @remote.delete '/'

  reactivate: (user) =>
    user.processing = true
    @remote.post('reactivate', user.serialize()).finally -> user.processing = false

  saveExperience: (experience) =>
    @remote.post('save_experience', experience: experience)

  removeExperience: (experience) =>
    @remote.post('save_experience', experience: experience, remove_experience: 1)

  emailStatus: (email, token) ->
    @fetch
      path: 'email_status'
      params: _.pickBy({email: email, token: token}, _.identity)
