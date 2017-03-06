angular.module('loomioApp').factory 'UserModel', (BaseModel, AppConfig) ->
  class UserModel extends BaseModel
    @singular: 'user'
    @plural: 'users'
    @apiEndPoint: 'profile'
    @serializableAttributes: AppConfig.permittedParams.user

    relationships: ->
      # note we should move these to a User extends UserModel so that all our authors don't get views created
      @hasMany 'memberships'
      @hasMany 'notifications'
      @hasMany 'contacts'
      @hasMany 'versions'

    membershipFor: (group) ->
      _.first @recordStore.memberships.find(groupId: group.id, userId: @id)

    groupIds: ->
      _.map(@memberships(), 'groupId')

    groups: ->
      groups = _.filter @recordStore.groups.find(id: { $in: @groupIds() }), (group) -> !group.isArchived()
      _.sortBy groups, 'fullName'

    parentGroups: ->
      _.filter @groups(), (group) -> group.isParent()

    hasAnyGroups: ->
      @groups().length > 0

    hasMultipleGroups: ->
      @groups().length > 1

    allThreads:->
      _.flatten _.map @groups(), (group) ->
        group.discussions()

    orphanSubgroups: ->
      _.filter @groups(), (group) =>
        group.isSubgroup() and !@isMemberOf(group.parent())

    orphanParents: ->
      _.uniq _.map @orphanSubgroups(), (group) =>
        group.parent()

    isAuthorOf: (object) ->
      @id == object.authorId

    isAdminOf: (group) ->
      _.contains(group.adminIds(), @id)

    isMemberOf: (group) ->
      _.contains(group.memberIds(), @id)

    firstName: ->
      @name.split(' ')[0]

    lastName: ->
      @name.split(' ').slice(1).join(' ')

    saveVolume: (volume, applyToAll) ->
      @remote.post('set_volume',
        volume: volume
        apply_to_all: applyToAll
        unsubscribe_token: @unsubscribeToken).then =>
        return unless applyToAll
        _.each @allThreads(), (thread) ->
          thread.update(discussionReaderVolume: null)
        _.each @memberships(), (membership) ->
          membership.update(volume: volume)

    hasExperienced: (key, group) ->
      if group && @isMemberOf(group)
        @membershipFor(group).experiences[key]
      else
        @experiences[key]

    hasProfilePhoto: ->
      @avatarKind != 'initials'

    belongsToPayingGroup: ->
      _.any @groups(), (group) -> group.subscriptionKind == 'paid'
