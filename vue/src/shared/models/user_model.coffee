import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import { find, invokeMap, filter, flatten, uniq, head, compact, some, map } from 'lodash-es'

export default class UserModel extends BaseModel
  @singular: 'user'
  @plural: 'users'

  relationships: ->
    @hasMany 'memberships'
  #   @hasMany 'notifications'
  #   @hasMany 'contacts'
  #   @hasMany 'versions'
  #   @hasMany 'reactions'

  defaultValues: ->
    shortBio: ''
    shortBioFormat: 'html'
    files: []
    imageFiles: []
    attachments: []
    locale: AppConfig.defaultLocale
    experiences: []

  localeName: ->
    (find(AppConfig.locales, (h) => h.key == @locale) or {}).name

  adminMemberships: ->
    @recordStore.memberships.find(userId: @id, admin: true)

  groupIds: ->
    map(@memberships(), 'groupId')

  groups: ->
    @recordStore.groups.collection.chain().
      find(id: { $in: @groupIds() }).
      simplesort('fullName').data()

  parentGroups: ->
    filter @groups(), (group) -> group.isParent()

  inboxGroups: ->
    flatten [@parentGroups(), @orphanSubgroups()]

  allThreads: ->
    flatten @groups().map (group) ->
      group.discussions()

  orphanSubgroups: ->
    filter @groups(), (group) =>
      group.parent() and !group.parent().membersInclude(@)

  orphanParents: ->
    uniq @orphanSubgroups().map (group) ->
      group.parent()

  membershipFor: (group) ->
    return unless group
    @recordStore.memberships.find(groupId: group.id, userId: @id)[0]

  firstName: ->
    head @name.split(' ') if @name

  saveVolume: (volume, applyToAll) ->
    @processing = true
    @remote.post('set_volume',
      volume: volume
      apply_to_all: applyToAll
      unsubscribe_token: @unsubscribeToken
    ).then =>
      return unless applyToAll
      @allThreads().forEach (thread) ->
        thread.update(discussionReaderVolume: null)
      @memberships().forEach (membership) ->
        membership.update(volume: volume)
    .finally =>
      @processing = false

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
    compact([@name, @titleFor(model)]).join(' · ')

  titleFor: (model) ->
    return unless model && model.group()
    (model.group().membershipFor(@) || {}).title
