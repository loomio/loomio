angular.module('loomioApp').factory 'AnalyticsService', ($location, $rootScope, $timeout, AppConfig) ->
  class AnalyticsService
    data =
      dimension4: AppConfig.version
      dimension5: AppConfig.currentUserId
      dimension6: 1

    setVersion: (version) ->
      data.dimension4 = version

    setUser: (user) ->
      data.dimension5 = user.id

    setGroup: (group) ->
      data.dimension1 = group.id
      data.dimension2 = group.organisationId
      data.dimension3 = group.cohortId

    clearGroup: ->
      delete data.dimension1
      delete data.dimension2
      delete data.dimension3

    trackView: () ->
      # timeout is used as first page load of app has timing issues
      $timeout ->
        data.page = $location.path()
        if ga?
          ga 'set', data
          ga 'send', 'pageview'
      , 2000

  service = new AnalyticsService

  $rootScope.$on 'analyticsClearGroup', ->
    service.clearGroup()

  $rootScope.$on 'analyticsSetGroup', (event, group) ->
    service.setGroup(group)

  $rootScope.$watch ->
    $location.path()
  , (path) ->
    service.trackView()

  return service
