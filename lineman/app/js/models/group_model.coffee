angular.module('loomioApp').factory 'GroupModel', (BaseModel, RecordStoreService) ->
  class GroupModel extends BaseModel
    constructor: (data = {}) ->
      @id =                     data.id
      @key =                    data.key
      @name =                   data.name
      @description =            data.description
      @parentId =               data.parent_id
      @createdAt =              data.created_at
      @membersCanEditComments = data.members_can_edit_comments
      @membersCanRaiseMotions = data.members_can_raise_motions
      @membersCanVote =         data.members_can_vote
      @membersCanStartDiscussions     = data.members_can_start_discussions
      @discussionPrivacyOptions       = data.discussion_privacy_options
      @visibleTo = data.visible_to

    plural: 'groups'

    params: ->
      group:
        visible_to: @visibleTo

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

    admins: ->
      RecordStoreService.get('users', _.map(@memberships(), (membership) -> membership.userId if membership.admin))

    fullName: (separator = '>') ->
      if @parentId?
        "#{@parentName()} #{separator} #{@name}"
      else
        @name

    parent: ->
      RecordStoreService.get('groups', @parentId)

    parentName: ->
      @parent().name if @parentId?

    visibleToPublic: ->       @visibleTo == 'public'
    visibleToOrganization: -> @visibleTo == 'parent_members'
    visibleToMembers: ->      @visibleTo == 'members'