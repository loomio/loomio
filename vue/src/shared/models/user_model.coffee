import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class UserModel extends BaseModel
  @singular: 'user'
  @plural: 'users'
  relationships: ->
    # note we should move these to a User extends UserModel so that all our authors don't get views created
    @hasMany 'memberships'
    @hasMany 'notifications'
    @hasMany 'contacts'
    @hasMany 'versions'
    @hasMany 'identities'
    @hasMany 'reactions'

  defaultValues: ->
    shortBio: ''
    shortBioFormat: 'html'

  localeName: ->
    (_.find(AppConfig.locales, (h) => h.key == @locale) or {}).name

  identityFor: (type) ->
    _.find @identities(), (i) -> i.identityType == type

  membershipFor: (group) ->
    _.head @recordStore.memberships.find(groupId: group.id, userId: @id)

  adminMemberships: ->
    _.filter @memberships(), (m) -> m.admin

  groupIds: ->
    _.map(@memberships(), 'groupId')

  groups: ->
    @recordStore.groups.collection.chain().
      find(id: { $in: @groupIds() }, archivedAt: {'$exists': false}).
      simplesort('fullName').data()

  formalGroups: ->
    @recordStore.groups.collection.chain().
      find(id: { $in: @groupIds() }, type: "FormalGroup", archivedAt: {'$exists': false}).
      simplesort('fullName').data()

  adminGroups: ->
    _.invokeMap @adminMemberships(), 'group'

  adminGroupIds: ->
    _.invokeMap @adminMemberships(), 'groupId'

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
    @id == object.authorId if object

  isAdminOf: (group) ->
    _.includes(group.adminIds(), @id) if group

  isMemberOf: (group) ->
    _.includes(group.memberIds(), @id) if group

  firstName: ->
    _.head @name.split(' ') if @name

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

  uploadedAvatarUrl: (size = 'medium') ->
    return @avatarUrl if typeof @avatarUrl is 'string'
    @avatarUrl[size]

  nameWithTitle: (model) ->
    _.compact([@name, @titleFor(model)]).join(' · ')

  titleFor: (model) ->
    return unless model
    if model.isA('group')
      (@membershipFor(model) or {}).title
    else if model.isA('discussion')
      @titleFor(model.guestGroup()) or @titleFor(model.group())
    else if model.isA('poll')
      @titleFor(model.guestGroup()) or @titleFor(model.discussion()) or @titleFor(model.group())

  belongsToPayingGroup: ->
    _.some @groups(), (group) -> group.subscriptionKind == 'paid'
