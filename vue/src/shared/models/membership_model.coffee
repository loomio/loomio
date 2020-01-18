import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import compareAsc from 'date-fns/compareAsc'

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
    @user().nameWithTitle(@group()) if @user()

  userUsername: ->
    @user().username

  userEmail: ->
    @user().email

  groupName: ->
    @group().name

  target: ->
    (@group() if @group().type == "FormalGroup")             or
    @recordStore.discussions.find(guestGroupId: @groupId)[0] or
    @recordStore.polls.find(guestGroupId: @groupId)[0]

  saveVolume: (volume, applyToAll = false) ->
    @processing = true
    @remote.patchMember(@keyOrId(), 'set_volume',
      volume: volume
      apply_to_all: applyToAll
      unsubscribe_token: @user().unsubscribeToken
    ).then =>
      if applyToAll
        @recordStore.discussions.collection.find({ groupId: { $in: @group().organisationIds() } }).forEach((discussion) -> discussion.update(discussionReaderVolume: null))
        _.each @user().memberships(), (membership) ->
          membership.update(volume: volume)
      else
        _.each @group().discussions(), (discussion) ->
          discussion.update(discussionReaderVolume: null)
    .finally =>
      @processing = false

  resend: ->
    @remote.postMember(@keyOrId(), 'resend').then =>
      @resent = true

  isMuted: ->
    @volume == 'mute'

  beforeRemove: ->
    _.invokeMap(@recordStore.events.find('eventable.type': 'membership', 'eventable.id': @id), 'remove')
