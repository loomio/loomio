AppConfig     = require 'shared/services/app_config.coffee'
Session       = require 'shared/services/session.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').factory 'IntercomService', ($rootScope, $window, ModalService, ContactModal) ->
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
    has_custom_cover: group.hasCustomCover
    invitations_count: group.invitationsCount

  service = new class IntercomService
    available: ->
      $window? and $window.Intercom? and $window.Intercom.booted?

    boot: ->
      return unless $window? and $window.Intercom?
      user = Session.user()
      lastGroup = mapGroup(user.parentGroups()[0])

      $window.Intercom 'boot',
       admin_link: LmoUrlService.user(user, {}, { noStub: true, absolute: true, namespace: 'admin/users', key: 'id' })
       app_id: AppConfig.intercom.appId
       user_id: user.id
       user_hash: AppConfig.intercom.userHash
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
      $window.Intercom('shutdown')

    updateWithGroup: (group) ->
      return unless group? and @available()
      return if _.isEqual(lastGroup, mapGroup(group))
      return if group.isSubgroup()
      user = Session.user()
      return if !user.isMemberOf(group)
      lastGroup = mapGroup(group)
      $window.Intercom 'update',
        email: user.email
        user_id: user.id
        company: lastGroup

    contactUs: ->

      if @available()
        $window.Intercom('showNewMessage')
      else
        ModalService.open ContactModal

    $rootScope.$on 'logout', (event, group) ->
      service.shutdown()

  service
