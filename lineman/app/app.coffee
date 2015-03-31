angular.module('loomioApp', ['ngNewRouter',
                             'ui.bootstrap',
                             'pascalprecht.translate',
                             'ngSanitize',
                             'tc.chartjs',
                             'btford.markdown',
                             'angularFileUpload',
                             'mentio',
                             'ngAnimate',
                             'angular-inview',
                             'ui.gravatar',
                             'truncate']).config ($httpProvider, $locationProvider, $translateProvider, $componentLoaderProvider) ->

  # consume the csrf token from the page so form submissions can work
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

  $locationProvider.html5Mode(true)

  $translateProvider.
    useUrlLoader('/api/v1/translations/en').
    preferredLanguage('en')

  $componentLoaderProvider.setTemplateMapping (name) ->
    snakeName = _.snakeCase(name);
    'generated/components/' + snakeName + '/' + snakeName + '.html';

angular.module('loomioApp').controller 'AppController', ($scope, $rootScope, $router) ->
  $scope.currentComponent = 'nothing yet'
  $scope.title = ""

  $scope.keyboardShortcuts =
    27:  'pressedEsc'
    191: 'pressedSlash'
    38:  'pressedUpArrow'
    40:  'pressedDownArrow'

  $scope.$on 'currentComponent', (event, component) ->
    $scope.currentComponent = component

  $scope.$on 'setTitle', (event, title) ->
    $scope.title = title

  $scope.keyDown = (event) ->
    if key = $scope.keyboardShortcuts[event.which]
      $rootScope.$broadcast key, angular.element(document.activeElement)[0]

  $router.config([
    {path: '/dashboard', component: 'dashboardPage' },
    {path: '/d/:key', component: 'threadPage' },
    {path: '/d/:key/:stub', component: 'threadPage' },
    {path: '/m/:key/', component: 'proposalRedirect' },
    {path: '/m/:key/:stub', component: 'proposalRedirect' },
    {path: '/g/new', component: 'groupForm' },
    {path: '/g/:parentKey/subgroups/new', component: 'groupForm'},
    {path: '/g/:key/edit', component: 'groupForm' },
    {path: '/g/:key/memberships', component: 'membershipsPage'}
    {path: '/g/:key', component: 'groupPage' },
    {path: '/g/:key/:stub', component: 'groupPage' },
  ]);
  return
