angular.module('loomioApp').controller 'PreviousPollsPageController', ($scope, $rootScope, $routeParams, Records, AbilityService, TranslationService) ->
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

  @searchPolls = ->
    console.log('searching polls...', @fragment)

  @translations = TranslationService.eagerTranslate @,
    searchPlaceholder: 'previous_polls_page.search_activities'

  return
