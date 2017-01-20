angular.module('loomioApp').controller 'PreviousPollsPageController', ($scope, $rootScope, $routeParams, Records, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'previousPollsPage'})

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    Records.polls.fetchClosedByGroup(@group.key).then =>
      Records.stances.fetchMyStances(@group.key) if AbilityService.isLoggedIn()
    , throwPageError
  , throwPageError

  throwPageError = (error) ->
    $rootScope.$broadcast('pageError', error)

  @pollCollection =
    polls: => @group.closedPolls() if @group?

  @loadMore = ->
    console.log('loading more...')

  return
