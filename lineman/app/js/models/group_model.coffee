angular.module('loomioApp').factory 'GroupModel', (BaseModel, RecordStoreService) ->
  class GroupModel extends BaseModel
    constructor: (data = {}) ->
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
      @logoUrlSmall                   = data.logo_url_small

    plural: 'groups'

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
      RecordStoreService.get 'discussions', (discussion) =>
        discussion.groupId == @id

    subgroups: ->
      RecordStoreService.get 'groups', (group) =>
        group.parentId == @id

    memberships: ->
      RecordStoreService.get 'memberships', (membership) =>
        membership.groupId == @id

    members: ->
      RecordStoreService.get('users', _.map(@memberships(), (membership) -> membership.userId))

    memberIds: ->
      _.map @memberships(), (membership) -> membership.userId

    adminMemberships: ->
      _.filter @memberships(), (membership) -> membership.admin

    adminIds: ->
      _.map @adminMemberships(), (membership) -> membership.userId

    fullName: (separator = '>') ->
      if @parentId?
        "#{@parentName()} #{separator} #{@name}"
      else
        @name

    parent: ->
      RecordStoreService.get('groups', @parentId)

    parentName: ->
      @parent().name if @parent()?

    parentIsHidden: ->
      @parent().visibleToPublic() if @parent()?

    visibleToPublic: ->       @visibleTo == 'public'
    visibleToOrganization: -> @visibleTo == 'parent_members'
    visibleToMembers: ->      @visibleTo == 'members'