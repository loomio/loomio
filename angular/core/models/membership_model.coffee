angular.module('loomioApp').factory 'MembershipModel', (BaseModel, AppConfig) ->
  class MembershipModel extends BaseModel
    @singular: 'membership'
    @plural: 'memberships'
    @indices: ['id', 'userId', 'groupId']
    @searchableFields: ['userName', 'userUsername']
    @serializableAttributes: AppConfig.permittedParams.membership

    relationships: ->
      @belongsTo 'group'
      @belongsTo 'user'
      @belongsTo 'inviter', from: 'users'

    userName: ->
      @user().name

    userUsername: ->
      @user().username

    groupName: ->
      @group().name

    saveVolume: (volume, applyToAll = false) ->
      @remote.patchMember(@keyOrId(), 'set_volume', { volume: volume, apply_to_all: applyToAll }).then =>
        if applyToAll
          _.each @user().allThreads(), (thread) ->
            thread.update(discussionReaderVolume: null)
          _.each @user().memberships(), (membership) ->
            membership.update(volume: volume)
        else
          _.each @group().discussions(), (discussion) ->
            discussion.update(discussionReaderVolume: null)

    isMuted: ->
      @volume == 'mute'
