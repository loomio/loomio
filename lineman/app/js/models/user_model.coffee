angular.module('loomioApp').factory 'UserModel', (RecordStoreService) ->
  class UserModel
    constructor: (data = {}) ->
      @id = data.id
      @name = data.name
      @label = data.username
      @avatarKind = data.avatar_kind
      @avatarUrl = data.avatar_url
      @avatarInitials = data.avatar_initials

    plural: 'users'

    membershipFor: (group) ->
      _.find @memberships(), (membership) -> membership.groupId == group.id

    memberships: ->
      RecordStoreService.get 'memberships', (membership) => membership.userId == @id

    notifications: ->
      RecordStoreService.get 'notifications', (notification) => notification.userId == @id

    groups: ->
      RecordStoreService.get('groups', _.map(@memberships(), (membership) -> membership.groupId))

    canEditComment: (comment) ->
      @isAuthorOf(comment) && comment.group().membersCanEditComments

    canDeleteComment: (comment) ->
      @isAuthorOf(comment) or @isAdminOf(comment.group())

    canEditDiscussion: (discussion) ->
      @isAuthorOf(discussion) or @isAdminOf(discussion.group()) or discussion.group().membersCanEditDiscussions

    isAuthorOf: (object) ->
      @id == object.authorId

    isAdminOf: (group) ->
      _.contains(group.adminIds(), @id)