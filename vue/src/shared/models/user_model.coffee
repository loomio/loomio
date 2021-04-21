import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import { find, invokeMap, filter, flatten, uniq, head, compact, some, map, truncate  } from 'lodash'

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
    linkPreviews: []
    locale: AppConfig.defaultLocale
    experiences: []

  nameOrEmail: ->
    @name || @email || @placeholderName

  simpleBio: ->
    truncate((@shortBio || '').replace(/<\/?[^>]+(>|$)/g, ""), length: 70)

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
    filter @groups(), (group) -> !group.parentId

  inboxGroups: ->
    flatten [@parentGroups(), @orphanSubgroups()]

  allThreads: ->
    flatten @groups().map (group) ->
      group.discussions()

  orphanSubgroups: ->
    filter @groups(), (group) =>
      group.parentId and !group.parent().membersInclude(@)

  orphanParents: ->
    uniq compact @orphanSubgroups().map (group) ->
      group.parentId && group.parent()

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

  title: (group) ->
    @titles[group.id] || @titles[group.parentId]

  nameWithTitle: (group) ->
    name = @nameOrEmail()
    return name unless group
    titles = @titles || {}
    compact([name, (titles[group.id] || titles[group.parentId])]).join(' · ')
