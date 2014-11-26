angular.module('loomioApp').factory 'GroupModel', (BaseModel) ->
  class GroupModel extends BaseModel
    plural: 'groups'

    hydrate: (data) ->
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
      @logoUrlSmall                   = data.logo_url_small

      #@discussionsView = RecordStore.discussions.belongingTo(@)
      #@subgroupsView = RecordStore.groups.belongingTo(owner: @, foreignKey: 'parentId')

    params: ->
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

    discussions: ->
      @recordStore.discussions.find(groupId: @primaryId)

    subgroups: ->
      @recordStore.groups.find(parentId: @primaryId)

    memberships: ->
      @recordStore.memberships.find(groupId: @primaryId)

    adminMemberships: ->
      _.filter memberships(), (membership) ->
        membership.groupId = @primaryId

    members: ->
      memberIds = _.map(@memberships(), (membership) -> membership.userId)
      @recordStore.users.find(id: {$in: memberIds})

    admins: ->
      adminIds = _.map(@adminMemberships(), (membership) -> membership.userId)
      @recordStore.users.find(id: {$in: adminIds})

    fullName: (separator = '>') ->
      if @parentId?
        "#{@parentName()} #{separator} #{@name}"
      else
        @name

    parent: ->
      @recordStore.groups.get(@parentId)

    parentName: ->
      @parent().name if @parent()?

    parentIsHidden: ->
      @parent().visibleToPublic() if @parent()?

    visibleToPublic: ->       @visibleTo == 'public'
    visibleToOrganization: -> @visibleTo == 'parent_members'
    visibleToMembers: ->      @visibleTo == 'members'
