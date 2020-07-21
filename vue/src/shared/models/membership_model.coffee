import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import compareAsc from 'date-fns/compareAsc'
import {each, invokeMap} from 'lodash-es'

export default class MembershipModel extends BaseModel
  @singular: 'membership'
  @plural: 'memberships'
  @indices: ['id', 'userId', 'groupId']
  @searchableFields: ['userName', 'userUsername']

  relationships: ->
    @belongsTo 'group'
    @belongsTo 'user'
    @belongsTo 'inviter', from: 'users'

  userName: ->
    @user().nameWithTitle(@group())

  userUsername: ->
    @user().username

  userEmail: ->
    @user().email

  groupName: ->
    @group().name

  saveVolume: (volume, applyToAll = false) ->
    @processing = true
    @remote.patchMember(@keyOrId(), 'set_volume',
      volume: volume
      apply_to_all: applyToAll
      unsubscribe_token: @user().unsubscribeToken
    ).then =>
      if applyToAll
        @recordStore.discussions.collection.find({ groupId: { $in: @group().organisationIds() } }).forEach((discussion) -> discussion.update(discussionReaderVolume: null))
        each @user().memberships(), (membership) ->
          membership.update(volume: volume)
      else
        each @group().discussions(), (discussion) ->
          discussion.update(discussionReaderVolume: null)
    .finally =>
      @processing = false

  resend: ->
    @remote.postMember(@keyOrId(), 'resend').then =>
      @resent = true

  isMuted: ->
    @volume == 'mute'

  beforeRemove: ->
    invokeMap(@recordStore.events.find('eventable.type': 'membership', 'eventable.id': @id), 'remove')
