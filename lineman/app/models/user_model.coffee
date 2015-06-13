angular.module('loomioApp').factory 'UserModel', (BaseModel) ->
  class UserModel extends BaseModel
    @singular: 'user'
    @plural: 'users'
    @indices: ['id']

    initialize: (data) ->
      @updateFromJSON(data)
      @label = data.username

    setupViews: ->
      @membershipsView   = @recordStore.memberships.belongingTo(userId: @id)
      @notificationsView = @recordStore.notifications.belongingTo(userId: @id)
      @contactsView      = @recordStore.contacts.belongingTo(userId: @id)
      @groupsView        = @recordStore.groups.belongingTo(id: { $in: @groupIds() })
      @parentGroupsView  = @recordStore.groups.collection.addDynamicView()
      @parentGroupsView.applyFind(parentId: {$eq: null}).applyFind(id: {$in: @groupIds()})

    groupIds: ->
      _.map(@memberships(), 'groupId')

    membershipFor: (group) ->
      _.first @recordStore.memberships
                          .collection.chain()
                          .find(groupId: group.id)
                          .find(userId: @id).data()

    memberships: ->
      @membershipsView.data()

    notifications: ->
      @notificationsView.data()

    contacts: ->
      @contactsView.data() 
      # we can just assume all contacts are CurrentUser... but this still feels nice.
      # also it's feeling more and more like we need to separate out CurrentUser concerns
      # (like abilities) from regular other user concerns.

    groups: ->
      @recordStore.groups.find(id: { $in: @groupIds() })

    parentGroups: ->
      @parentGroupsView.data()

    canInviteTo: (group) ->
      @membershipFor(group).admin or (@membershipFor(group) and group.membersCanAddMembers)

    canEditComment: (comment) ->
      @isAuthorOf(comment) && comment.group().membersCanEditComments

    canDeleteComment: (comment) ->
      @isAuthorOf(comment) or @isAdminOf(comment.group())

    canEditDiscussion: (discussion) ->
      @isAuthorOf(discussion) or
      @isAdminOf(discussion.group()) or
      discussion.group().membersCanEditDiscussions

    canStartProposals: (discussion) ->
      @isAdminOf(discussion.group()) or
      discussion.group().membersCanRaiseProposals

    canEditProposal: (proposal) ->
      proposal.isActive() and
      proposal.canBeEdited() and
      (@isAdminOf(proposal.group()) or @isAuthorOf(proposal))

    canCloseOrExtendProposal: (proposal) ->
      proposal.isActive() and
      (@isAdminOf(proposal.group()) or @isAuthorOf(proposal))

    canSeePrivateContentFor: (group) ->
      group.visibleTo == 'public' or
      @isMemberOf(group) or
      (group.visibleTo == 'parent_members' and @isMemberOf(group.parent()))

    isAuthorOf: (object) ->
      @id == object.authorId

    isAdminOf: (group) ->
      _.contains(group.adminIds(), @id)

    isMemberOf: (group) ->
      _.contains(group.memberIds(), @id)
