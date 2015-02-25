angular.module('loomioApp').factory 'GroupModel', (BaseModel) ->
  class GroupModel extends BaseModel
    @singular: 'group'
    @plural: 'groups'
    @indices: ['parentId']

    setupViews: ->
      @discussionsView = @recordStore.discussions.collection.addDynamicView(@viewName())
      @discussionsView.applyFind(groupId: @id)
      @discussionsView.applySimpleSort('createdAt', true)

    discussions: ->
      @discussionsView.data()

    subgroups: ->
      @recordStore.groups.find(parentId: @id)

    memberships: ->
      @recordStore.memberships.find(groupId: @id)

    membershipFor: (user) ->
      _.find @memberships(), (membership) -> membership.userId == user.id

    members: ->
      memberIds = _.map(@memberships(), (membership) -> membership.userId)
      @recordStore.users.find(id: {$in: memberIds})

    adminMemberships: ->
      _.filter @memberships(), (membership) -> membership.admin

    admins: ->
      adminIds = _.map(@adminMemberships(), (membership) -> membership.userId)
      @recordStore.users.find(id: {$in: adminIds})

    memberIds: ->
      _.map @memberships(), (membership) -> membership.userId

    adminIds: ->
      _.map @adminMemberships(), (membership) -> membership.userId

    fullName: (separator = '>') ->
      if @parentId?
        "#{@parentName()} #{separator} #{@name}"
      else
        @name

    parent: ->
      @recordStore.groups.find(@parentId)

    parentName: ->
      @parent().name if @parent()?

    parentIsHidden: ->
      @parent().visibleToPublic() if @parentId?

    visibleToPublic: ->       @visibleTo == 'public'
    visibleToOrganization: -> @visibleTo == 'parent_members'
    visibleToMembers: ->      @visibleTo == 'members'

    userDefinedLogo: ->
      !_.contains(@logoUrlMedium, 'default-logo')

    userDefinedCover: ->
      !_.contains(@coverUrlDesktop, 'default-cover')

    isSubgroup: ->
      @parentId?

    logoUrl: ->
      if @isSubgroup() && !@userDefinedLogo()
        @parent().logoUrlMedium
      else
        @logoUrlMedium

    coverUrl: ->
      if @isSubgroup() && !@userDefinedCover()
        @parent().coverUrlDesktop
      else
        @coverUrlDesktop

    archive: ->
      @restfulClient.postMember(group.key, 'archive')
