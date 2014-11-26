angular.module('loomioApp').factory 'UserModel', ->
  class UserModel extends BaseModel
    plural: 'users'

    hydrate: (data) ->
      @name = data.name
      @label = data.username
      @avatarKind = data.avatar_kind
      @avatarUrl = data.avatar_url
      @avatarInitials = data.avatar_initials

    membershipFor: (group) ->
      _.find @memberships(), (membership) -> membership.groupId == group.id

    memberships: ->
      @recordStore.memberships.find(userId: @primaryId)

    notifications: ->
      @recordStore.notifications.find(userId: @primaryId)

    groups: ->
      group_ids = _.map(@memberships(), (membership) -> membership.groupId) 
      @recordStore.groups.get(group_ids)
