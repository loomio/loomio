angular.module('loomioApp').factory 'GroupModel', (BaseModel) ->
  class GroupModel extends BaseModel
    @singular: 'group'
    @plural: 'groups'
    @indexes: ['parentId']

    initialize: (data) ->
      @id                             = data.id
      @key                            = data.key
      @name                           = data.name
      @description                    = data.description
      @parentId                       = data.parent_id
      @createdAt                      = data.created_at
      @membersCanAddMembers           = data.members_can_add_members
      @membersCanCreateSubgroups      = data.members_can_create_subgroups
      @membersCanStartDiscussions     = data.members_can_start_discussions
      @membersCanEditDiscussions      = data.members_can_edit_discussions
      @membersCanEditComments         = data.members_can_edit_comments
      @membersCanRaiseMotions         = data.members_can_raise_motions
      @membersCanVote                 = data.members_can_vote
      @membershipGrantedUpon          = data.membership_granted_upon
      @discussionPrivacyOptions       = data.discussion_privacy_options
      @visibleTo                      = data.visible_to
      @logoUrlMedium                  = data.logo_url_medium
      @coverUrlDesktop                = data.cover_url_desktop

    serialize: ->
      group:
        name:                          @name
        description:                   @description
        parent_id:                     @parentId
        members_can_add_members:       @membersCanAddMembers
        members_can_create_subgroups:  @membersCanCreateSubgroups
        members_can_start_discussions: @membersCanStartDiscussions
        members_can_edit_discussions:  @membersCanEditDiscussions
        members_can_edit_comments:     @membersCanEditComments
        members_can_raise_motions:     @membersCanRaiseMotions
        members_can_vote:              @membersCanVote
        membership_granted_upon:       @membershipGrantedUpon
        discussion_privacy_options:    @discussionPrivacyOptions
        visible_to:                    @visibleTo

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
