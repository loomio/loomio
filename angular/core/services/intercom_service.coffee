angular.module('loomioApp').factory 'IntercomService', ($rootScope, $window, AppConfig, CurrentUser, LmoUrlService) ->
  currentGroup = null
  service = new class IntercomService
    available: ->
      $window? and $window.Intercom? and $window.Intercom.booted?

    boot: ->
      return unless $window? and $window.Intercom?
      firstGroup = CurrentUser.groups()[0]

      $window.Intercom 'boot',
       admin_link: AppConfig.baseUrl+"/admin/users/#{CurrentUser.id}"
       app_id: AppConfig.intercomAppId
       user_id: CurrentUser.id
       user_hash: AppConfig.intercomUserHash
       email: CurrentUser.email
       name: CurrentUser.name
       username: CurrentUser.username
       user_id: CurrentUser.id
       created_at: CurrentUser.createdAt
       angular_ui: true
       locale: CurrentUser.locale
       company: firstGroup

    shutdown: ->
      return unless @available()
      $window.Intercom('shutdown')

    updateWithGroup: (group) ->
      return if currentGroup == group
      currentGroup = group
      return unless @available()
      $window.Intercom 'update',
        email: CurrentUser.email
        user_id: CurrentUser.id
        company:
          id: group.id
          key: group.key
          name: group.name
          admin_link: AppConfig.baseUrl+"/admin/groups/#{group.key}"
          subscription_kind: group.subscriptionKind
          subscription_plan: group.subscriptionPlan
          subscription_expires_at: group.subscriptionExpiresAt
          creator_id: group.creatorId
          group_privacy: group.groupPrivacy
          cohort_id: group.cohortId
          created_at: group.createdAt
          locale: CurrentUser.locale
          proposals_count: group.proposalsCount
          discussions_count: group.discussionsCount
          memberships_count: group.membershipsCount

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
