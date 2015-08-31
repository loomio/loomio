angular.module('loomioApp').factory 'IntercomService', ($rootScope, $http, AppConfig, CurrentUser) ->
  currentGroup = null
  service = new class IntercomService
    boot: ->
      return unless window? and window.Intercom?
      window.Intercom 'boot',
       app_id: AppConfig.intercomAppId
       user_id: CurrentUser.id
       user_hash: AppConfig.intercomUserHash
       email: CurrentUser.email
       user_id: CurrentUser.id
       created_at: CurrentUser.createdAt

    shutdown: ->
      return unless window? and window.Intercom?
      window.Intercom('shutdown')

    updateWithGroup: (group) ->
      return if currentGroup == group
      currentGroup = group
      return unless window? and window.Intercom?
      window.Intercom 'update',
        email: CurrentUser.email
        user_id: CurrentUser.id
        company:
          id: group.id
          key: group.key
          name: group.name
          description: group.description
          creator_id: group.creatorId
          visible_to: group.visibleTo
          cohort_id: group.cohortId

  $rootScope.$on 'analyticsSetGroup', (event, group) ->
    service.updateWithGroup(group)

  $rootScope.$on 'logout', (event, group) ->
    service.shutdown()

  service
