angular.module('loomioApp').controller 'PreviousPollsPageController', ($scope, $rootScope, $routeParams, Records, AbilityService, TranslationService, LoadingService) ->
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
    polls: =>
      return unless @group?
      _.filter @group.closedPolls(), (poll) =>
        _.isEmpty(@fragment) or poll.title.match(@fragment)

  @loadMore = ->
    console.log('loading more...')

  @searchPolls = =>
    Records.polls.search(@group.key, @fragment, per: 10)
  LoadingService.applyLoadingFunction @, 'searchPolls'

  @translations = TranslationService.eagerTranslate @,
    searchPlaceholder: 'previous_polls_page.search_activities'

  return
