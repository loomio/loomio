BaseModel = require 'shared/record_store/base_model.coffee'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class UserModel extends BaseModel
  @singular: 'user'
  @plural: 'users'
  @apiEndPoint: 'profile'
  @serializableAttributes: AppConfig.permittedParams.user

  relationships: ->
    # note we should move these to a User extends UserModel so that all our authors don't get views created
    @hasMany 'memberships'
    @hasMany 'notifications'
    @hasMany 'contacts'
    @hasMany 'versions'
    @hasMany 'identities'
    @hasMany 'reactions'

  localeName: ->
    (_.find(AppConfig.locales, (h) => h.key == @locale) or {}).name

  identityFor: (type) ->
    _.detect @identities(), (i) -> i.identityType == type

  membershipFor: (group) ->
    _.first @recordStore.memberships.find(groupId: group.id, userId: @id)

  adminMemberships: ->
    _.filter @memberships(), (m) -> m.admin

  groupIds: ->
    _.map(@memberships(), 'groupId')

  groups: ->
    groups = _.filter @recordStore.groups.find(id: { $in: @groupIds() }), (group) -> !group.isArchived()
    _.sortBy groups, 'fullName'

  adminGroups: ->
    _.invoke @adminMemberships(), 'group'

  adminGroupIds: ->
    _.invoke @adminMemberships(), 'groupId'

  parentGroups: ->
    _.filter @groups(), (group) -> group.isParent()

  inboxGroups: ->
    _.flatten [@parentGroups(), @orphanSubgroups()]

  hasAnyGroups: ->
    @groups().length > 0

  hasMultipleGroups: ->
    @groups().length > 1

  allThreads:->
    _.flatten _.map @groups(), (group) ->
      group.discussions()

  orphanSubgroups: ->
    _.filter @groups(), (group) =>
      group.isSubgroup() and !@isMemberOf(group.parent())

  orphanParents: ->
    _.uniq _.map @orphanSubgroups(), (group) =>
      group.parent()

  isAuthorOf: (object) ->
    @id == object.authorId

  isAdminOf: (group) ->
    _.contains(group.adminIds(), @id)

  isMemberOf: (group) ->
    _.contains(group.memberIds(), @id)

  firstName: ->
    _.first @name.split(' ') if @name

  lastName: ->
    @name.split(' ').slice(1).join(' ')

  saveVolume: (volume, applyToAll) ->
    @remote.post('set_volume',
      volume: volume
      apply_to_all: applyToAll
      unsubscribe_token: @unsubscribeToken).then =>
      return unless applyToAll
      _.each @allThreads(), (thread) ->
        thread.update(discussionReaderVolume: null)
      _.each @memberships(), (membership) ->
        membership.update(volume: volume)

  remind: (model) ->
    @remote.postMember(@id, 'remind', {"#{model.constructor.singular}_id": model.id}).then =>
      @reminded = true

  hasExperienced: (key, group) ->
    if group && @isMemberOf(group)
      @membershipFor(group).experiences[key]
    else
      @experiences[key]

  hasProfilePhoto: ->
    @avatarKind != 'initials'

  belongsToPayingGroup: ->
    _.any @groups(), (group) -> group.subscriptionKind == 'paid'
