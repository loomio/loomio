angular.module('loomioApp').factory 'IntercomService', ($rootScope, $window, AppConfig, Session, LmoUrlService) ->
  currentGroup = null
  service = new class IntercomService
    available: ->
      $window? and $window.Intercom? and $window.Intercom.booted?

    boot: ->
      return unless $window? and $window.Intercom?
      firstGroup = Session.current().parentGroups()[0]

      $window.Intercom 'boot',
       admin_link: AppConfig.baseUrl+"/admin/users/#{Session.current().id}"
       app_id: AppConfig.intercomAppId
       user_id: Session.current().id
       user_hash: AppConfig.intercomUserHash
       email: Session.current().email
       name: Session.current().name
       username: Session.current().username
       user_id: Session.current().id
       created_at: Session.current().createdAt
       angular_ui: true
       locale: Session.current().locale
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
        email: Session.current().email
        user_id: Session.current().id
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
          locale: Session.current().locale
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
