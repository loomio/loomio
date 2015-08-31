angular.module('loomioApp', ['ngNewRouter',
                             'ui.bootstrap',
                             'pascalprecht.translate',
                             'ngSanitize',
                             'hc.marked',
                             'angularFileUpload',
                             'mentio',
                             'ngAnimate',
                             'angular-inview',
                             'ui.gravatar',
                             'truncate',
                             'duScroll']).config ($httpProvider, $locationProvider, $translateProvider, markedProvider, $compileProvider) ->

  #configure markdown
  renderer = new marked.Renderer()
  renderer.link = (href, title, text) ->
    "<a href='" + href + "' title='" + (title || text) + "' target='_blank'>" + text + "</a>";

  markedProvider.setOptions
    renderer: renderer
    gfm: true
    sanitize: true
    breaks: true

  # enable html5 pushstate mode
  $locationProvider.html5Mode(true)

  if window.Loomio?
    locale = window.Loomio.currentUserLocale
    $translateProvider.useUrlLoader("/api/v1/translations").
                       preferredLanguage(locale)

    $translateProvider.useSanitizeValueStrategy('sanitizeParameters');

  # disable angular debug stuff in production
  if window.Loomio? and window.Loomio.environment == 'production'
    $compileProvider.debugInfoEnabled(false);

# Finally the Application controller lives here.
angular.module('loomioApp').controller 'ApplicationController', ($scope, $filter, $rootScope, $router, KeyEventService, ScrollService, AnalyticsService, CurrentUser, MessageChannelService, IntercomService) ->
  IntercomService.boot()

  $scope.currentComponent = 'nothing yet'

  $scope.$on 'currentComponent', (event, options = {}) ->
    $scope.pageError = null
    ScrollService.scrollTo(options['scrollTo'] or 'h1')

  $scope.$on 'setTitle', (event, title) ->
    document.querySelector('title').text = _.trunc(title, 300) + ' | Loomio'

  $scope.$on 'pageError', (event, error) ->
    $scope.pageError = error

  $scope.$on 'currentUserMembershipsLoaded', ->
    _.each CurrentUser.groups(), (group) ->
      MessageChannelService.subscribeTo "/group-#{group.key}"


  $scope.keyDown = (event) -> KeyEventService.broadcast event

  $router.config([
    {path: '/dashboard', component: 'dashboardPage' },
    {path: '/inbox', component: 'inboxPage' },
    {path: '/groups', component: 'groupsPage' },
    {path: '/profile', component: 'profilePage'},
    {path: '/email_preferences', component: 'emailSettingsPage' },
    {path: '/d/:key', component: 'threadPage' },
    {path: '/d/:key/:stub', component: 'threadPage' },
    {path: '/m/:key/', component: 'proposalRedirect' },
    {path: '/m/:key/:stub', component: 'proposalRedirect' },
    {path: '/m/:key/votes/new', component: 'proposalRedirect' },
    {path: '/g/:key/memberships', component: 'membershipsPage'},
    {path: '/g/:key/membership_requests', component: 'membershipRequestsPage'},
    {path: '/g/:key', component: 'groupPage' },
    {path: '/g/:key/:stub', component: 'groupPage' }
  ])

  return
