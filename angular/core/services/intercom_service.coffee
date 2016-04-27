angular.module('loomioApp').factory 'IntercomService', ($rootScope, $window, AppConfig, User, LmoUrlService) ->
  currentGroup = null
  service = new class IntercomService
    available: ->
      $window? and $window.Intercom? and $window.Intercom.booted?

    boot: ->
      return unless $window? and $window.Intercom?
      firstGroup = User.current().parentGroups()[0]

      $window.Intercom 'boot',
       admin_link: AppConfig.baseUrl+"/admin/users/#{User.current().id}"
       app_id: AppConfig.intercomAppId
       user_id: User.current().id
       user_hash: AppConfig.intercom.userHash
       email: User.current().email
       name: User.current().name
       username: User.current().username
       user_id: User.current().id
       created_at: User.current().createdAt
       angular_ui: true
       locale: User.current().locale
       company: firstGroup

    shutdown: ->
      return unless @available()
      $window.Intercom('shutdown')

    updateWithGroup: (group) ->
      return unless @available()
      return if currentGroup == group
      return if group.isSubgroup()
      currentGroup = group
      $window.Intercom 'update',
        email: User.current().email
        user_id: User.current().id
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
          locale: User.current().locale
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
