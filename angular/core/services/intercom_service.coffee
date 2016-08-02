angular.module('loomioApp').factory 'IntercomService', ($rootScope, $window, AppConfig, Session, LmoUrlService) ->
  currentGroup = null
  mapGroup = (group) ->
    id: group.id
    key: group.key
    name: group.name
    description: group.description.substring(0, 250)
    admin_link: AppConfig.baseUrl+"/admin/groups/#{group.key}"
    subscription_kind: group.subscriptionKind
    subscription_plan: group.subscriptionPlan
    subscription_expires_at: group.subscriptionExpiresAt
    creator_id: group.creatorId
    group_privacy: group.groupPrivacy
    cohort_id: group.cohortId
    created_at: group.createdAt
    locale: group.locale
    motions_count: group.motionsCount
    discussions_count: group.discussionsCount
    memberships_count: group.membershipsCount
    closed_motions_count: group.closedMotionsCount
    has_custom_cover: group.hasCustomCover
    invitations_count: group.invitationsCount


  service = new class IntercomService
    available: ->
      $window? and $window.Intercom? and $window.Intercom.booted?

    boot: ->
      return unless $window? and $window.Intercom?
      firstGroup = Session.user().parentGroups()[0]

      $window.Intercom 'boot',
       admin_link: AppConfig.baseUrl+"/admin/users/#{Session.user().id}"
       app_id: AppConfig.intercomAppId
       user_id: Session.user().id
       user_hash: AppConfig.intercomUserHash
       email: Session.user().email
       name: Session.user().name
       username: Session.user().username
       user_id: Session.user().id
       created_at: Session.user().createdAt
       is_coordinator: Session.user().isCoordinator
       angular_ui: true
       locale: Session.user().locale
       company: mapGroup(firstGroup)

    shutdown: ->
      return unless @available()
      $window.Intercom('shutdown')

    updateWithGroup: (group) ->
      return unless @available()
      return if currentGroup == group
      return if group.isSubgroup()
      currentGroup = group
      $window.Intercom 'update',
        email: Session.user().email
        user_id: Session.user().id
        company: mapGroup(group)

    contactUs: ->
      if @available()
        $window.Intercom.public_api.showNewMessage()
      else
        $window.location = LmoUrlService.contactForm()

  $rootScope.$on 'analyticsSetGroup', (event, group) ->
    service.updateWithGroup(group)

  $rootScope.$on 'logout', (event, group) ->
    service.shutdown()

  service
