angular.module('loomioApp').factory 'UserModel', (BaseModel) ->
  class UserModel extends BaseModel
    @singular: 'user'
    @plural: 'users'

    initialize: (data) ->
      @id = data.id
      @name = data.name
      @label = data.username
      @profileUrl = data.profile_url
      @avatarKind = data.avatar_kind
      @avatarUrl = data.avatar_url
      @avatarInitials = data.avatar_initials

    setupViews: ->
      @membershipsView = @recordStore.memberships.addDynamicView(@viewName())
      @membershipsView.applyFind(userId: @id)
      @membershipsView.applySimpleSort('id')


    groupIds: ->
      _.map(@memberships(), 'groupId')

    membershipFor: (group) ->
      _.find @memberships(), (membership) -> membership.groupId == group.id

    memberships: ->
      @membershipsView.data()

    notifications: ->
      @recordStore.notifications.find(userId: @id)

    groups: ->
      groupSort = (first, second) ->
         return 0 if (first.fullName() == second.fullName())
         return 1 if (first.fullName() > second.fullName())
         return -1 if (first.fullName() < second.fullName())

      @recordStore.groups.chain()
                         .find(id: {'$in': @groupIds()})
                         .sort(groupSort)
                         .data()

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
