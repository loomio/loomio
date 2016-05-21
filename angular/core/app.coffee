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
                             'duScroll',
                             'angular-clipboard',
                             'checklist-model',
                             'monospaced.elastic',
                             'angularMoment',
                             'offClick']).config ($locationProvider, $translateProvider, markedProvider, $compileProvider, $animateProvider, renderProvider) ->

  # this should make stuff faster but you need to add "animated" class to animated things.
  # http://www.bennadel.com/blog/2935-enable-animations-explicitly-for-a-performance-boost-in-angularjs.htm
  $animateProvider.classNameFilter( /\banimated\b/ );

  markedProvider.setOptions
    renderer: renderProvider.$get(0).createRenderer()
    gfm: true
    sanitize: true
    breaks: true

  # enable html5 pushstate mode
  $locationProvider.html5Mode(!window.Loomio.mobileHost?)

  $translateProvider.useUrlLoader("#{[window.Loomio.mobileHost]}/api/v1/translations")
                    .preferredLanguage(window.Loomio.currentUserLocale)
                    .useSanitizeValueStrategy('escapeParameters')

  # disable angular debug stuff in production
  $compileProvider.debugInfoEnabled(window.Loomio.environment == 'production')

# Finally the Application controller lives here.
angular.module('loomioApp').controller 'ApplicationController', ($scope, $timeout, $location, $router, KeyEventService, MessageChannelService, TransitionService, IntercomService, ScrollService, Session, AppConfig, Records, ModalService, SignInForm, GroupForm, AngularWelcomeModal, ChoosePlanModal, AbilityService) ->
  $scope.isLoggedIn = AbilityService.isLoggedIn

  # NB: $scope.refresh triggers the ng-if for the ng-outlet in the layout.
  # This means that we re-initialize the controller for the page, which is what we want
  # for actions like logging in or out, without refreshing the whole app.
  $scope.refresh = ->
    $scope.pageError = null
    $scope.refreshing = true
    $timeout -> $scope.refreshing = false

  if document.location.protocol.match(/https/) && navigator.serviceWorker?
    navigator.serviceWorker.register(document.location.origin + '/service-worker.js', scope: './')

  $scope.$on 'loggedIn', (event, user) ->
    $scope.refresh()
    ModalService.open(GroupForm, group: -> Records.groups.build()) if $location.search().start_group?
    ModalService.open(AngularWelcomeModal)                         if AppConfig.showWelcomeModal
    IntercomService.boot()
    MessageChannelService.subscribe()
  Session.login(AppConfig.currentUserData)

  $scope.$on 'currentComponent', (event, options = {}) ->
    $scope.pageError = null

    if AbilityService.requireLoginFor(options.page)
      ModalService.open(SignInForm, preventClose: -> true)
    else if AbilityService.requireRedirectFor(options.page)
      $timeout -> $router.navigate(Session.homePath())
    else
      ScrollService.scrollTo(options.scrollTo or 'h1')

    $scope.links = options.links or {}

  $scope.$on 'setTitle', (event, title) ->
    document.querySelector('title').text = _.trunc(title, 300) + ' | Loomio'

  $scope.$on 'pageError', (event, error) ->
    $scope.pageError = error
    if !AbilityService.isLoggedIn() and error.status == 403
      ModalService.open(SignInForm, preventClose: -> true)

  $scope.$on 'trialIsOverdue', (event, group) ->
    if AbilityService.canAdministerGroup(group) and AppConfig.chargify and !AppConfig.chargify.nagCache[group.key]
      ModalService.open ChoosePlanModal, group: -> group
      AppConfig.chargify.nagCache[group.key] = true

  $scope.keyDown = (event) -> KeyEventService.broadcast event

  $router.config([
    {path: '/dashboard', component: 'dashboardPage' },
    {path: '/inbox', component: 'inboxPage' },
    {path: '/groups', component: 'groupsPage' },
    {path: '/explore', component: 'explorePage'},
    {path: '/profile', component: 'profilePage'},
    {path: '/email_preferences', component: 'emailSettingsPage' },
    {path: '/d/:key', component: 'threadPage' },
    {path: '/d/:key/:stub', component: 'threadPage' },
    {path: '/d/:key/comment/:comment', component: 'threadPage'},
    {path: '/d/:key/proposal/:proposal', component: 'threadPage'},
    {path: '/d/:key/proposal/:proposal/:outcome', component: 'threadPage'},
    {path: '/m/:key/', component: 'proposalRedirect' },
    {path: '/m/:key/:stub', component: 'proposalRedirect' },
    {path: '/m/:key/votes/new', component: 'proposalRedirect' },
    {path: '/g/:key/memberships', component: 'membershipsPage'},
    {path: '/g/:key/memberships/:username', component: 'membershipsPage'},
    {path: '/g/:key/membership_requests', component: 'membershipRequestsPage'},
    {path: '/g/:key/previous_proposals', component: 'previousProposalsPage'},
    {path: '/g/:key', component: 'groupPage' },
    {path: '/g/:key/:stub', component: 'groupPage' },
    {path: '/u/:key', component: 'userPage' },
    {path: '/u/:key/:stub', component: 'userPage' },
    {path: '/apps/authorized', component: 'authorizedAppsPage'},
    {path: '/apps/registered', component: 'registeredAppsPage'},
    {path: '/apps/registered/:id', component: 'registeredAppPage'},
    {path: '/apps/registered/:id/:stub', component: 'registeredAppPage'},
    {path: '/explore', component: 'explorePage'}
  ])
  $router.navigate('/dashboard') if AppConfig.mobileHost?

  Session.login(AppConfig.currentUserData)

  return
