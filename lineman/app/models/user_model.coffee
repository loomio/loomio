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

    membershipFor: (group) ->
      _.first @recordStore.memberships
                          .collection.chain()
                          .find(groupId: group.id)
                          .find(userId: @id).data()

    memberships: ->
      @membershipsView.data()

    groupIds: ->
      _.map(@memberships(), 'groupId')

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
      _.filter @groups(), (group) -> group.parentId == null

    isAuthorOf: (object) ->
      @id == object.authorId

    isAdminOf: (group) ->
      _.contains(group.adminIds(), @id)

    isMemberOf: (group) ->
      _.contains(group.memberIds(), @id)
