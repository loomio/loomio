angular.module('loomioApp').factory 'UserModel', (BaseModel) ->
  class UserModel extends BaseModel
    @singular: 'user'
    @plural: 'users'
    @indices: ['id']

    initialize: (data) ->
      @baseInitialize(data)
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

    isAuthorOf: (object) ->
      @id == object.authorId

    isAdminOf: (group) ->
      _.contains(group.adminIds(), @id)

    isMemberOf: (group) ->
      _.contains(group.memberIds(), @id)
