angular.module('loomioApp').factory 'UserModel', (BaseModel) ->
  class UserModel extends BaseModel
    @singular: 'user'
    @plural: 'users'

    initialize: (data) ->
      @id = data.id
      @name = data.name
      @label = data.username
      @avatarKind = data.avatar_kind
      @avatarUrl = data.avatar_url
      @avatarInitials = data.avatar_initials

    membershipFor: (group) ->
      _.find @memberships(), (membership) -> membership.groupId == group.id

    memberships: ->
      @recordStore.memberships.find(userId: @id)

    notifications: ->
      @recordStore.notifications.find(userId: @id)

    groups: ->
      group_ids = _.map(@memberships(), (membership) -> membership.groupId) 
      @recordStore.groups.get(group_ids)

    canEditComment: (comment) ->
      @isAuthorOf(comment) && comment.group().membersCanEditComments

    canDeleteComment: (comment) ->
      @isAuthorOf(comment) or @isAdminOf(comment.group())

    canEditDiscussion: (discussion) ->
      @isAuthorOf(discussion) or @isAdminOf(discussion.group()) or discussion.group().membersCanEditDiscussions

    canStartProposals: (discussion) ->
      @isAdminOf(discussion.group()) or discussion.group().membersCanStartProposals

    isAuthorOf: (object) ->
      @id == object.authorId

    isAdminOf: (group) ->
      _.contains(group.adminIds(), @id)

    isMemberOf: (group) ->
      _.contains(group.memberIds(), @id)
