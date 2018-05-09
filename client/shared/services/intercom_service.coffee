AppConfig     = require 'shared/services/app_config.coffee'
Session       = require 'shared/services/session.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

lastGroup = {}

mapGroup = (group) ->
  return null unless group? && group.createdAt?
  id: group.id
  company_id: group.id
  key: group.key
  name: group.name
  description: (group.description || "").substring(0, 250)
  admin_link: LmoUrlService.group(group, {}, { noStub: true, absolute: true, namespace: 'admin/groups' })
  plan: group.subscriptionKind
  subscription_kind: group.subscriptionKind
  subscription_plan: group.subscriptionPlan
  subscription_expires_at: group.subscriptionExpiresAt? && group.subscriptionExpiresAt.format()
  creator_id: group.creatorId
  group_privacy: group.groupPrivacy
  cohort_id: group.cohortId
  created_at: group.createdAt.format()
  discussions_count: group.discussionsCount
  memberships_count: group.membershipsCount
  pending_memberships_count: group.pendingMembershipsCount
  has_custom_cover: group.hasCustomCover

module.exports = new class IntercomService
  available: ->
    window and window.Intercom and window.Intercom.booted?

  fetch: ->
    return if !window or !Session.user() or window.Intercom
    if typeof ic is 'function'
      ic('reattach_activator')
      ic('update', intercomSettings)
    else
      fetchIntercom = ->
        script = document.createElement('script')
        script.type = 'text/javascript'
        script.async = true
        script.src = "https://widget.intercom.io/widget/#{AppConfig.intercomAppId}"
        prev = _.first document.getElementsByTagName('script')
        prev.parentNode.insertBefore(prev, script)
      if window.attachEvent
        window.attachEvent 'onload', fetchIntercom
      else
        window.addEventListener 'load', fetchIntercom, false

  boot: ->
    return unless window.Intercom
    user = Session.user()
    lastGroup = mapGroup(user.parentGroups()[0])

    window.Intercom 'boot',
     admin_link: LmoUrlService.user(user, {}, { noStub: true, absolute: true, namespace: 'admin/users', key: 'id' })
     app_id: AppConfig.intercomAppId
     user_id: user.id
     user_hash: user.intercomHash
     email: user.email
     name: user.name
     username: user.username
     user_id: user.id
     created_at: user.createdAt
     is_coordinator: user.isCoordinator
     locale: user.locale
     company: lastGroup
     has_profile_photo: user.hasProfilePhoto()
     belongs_to_paying_group: user.belongsToPayingGroup()

  shutdown: ->
    return unless @available()
    window.Intercom('shutdown')

  updateWithGroup: (group) ->
    return unless group? and @available()
    return if _.isEqual(lastGroup, mapGroup(group))
    return if group.isSubgroup() or group.type != 'FormalGroup'
    user = Session.user()
    return if !user.isMemberOf(group)
    lastGroup = mapGroup(group)
    window.Intercom 'update',
      email: user.email
      user_id: user.id
      company: lastGroup

  open: ->
    return unless @available()
    window.Intercom('showNewMessage')
