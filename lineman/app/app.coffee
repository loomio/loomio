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
                             'truncate', 'duScroll']).config ($httpProvider, $locationProvider, $translateProvider, $componentLoaderProvider) ->

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

angular.module('loomioApp').controller 'AppController', ($scope, $filter, $rootScope, $router, KeyEventService) ->
  $scope.currentComponent = 'nothing yet'

  $scope.$on 'currentComponent', ->
    $scope.pageError = null
    angular.element(document.querySelector('.main-container'))

  $scope.$on 'setTitle', (event, title) ->
    angular.element.find('title')[0].text = _.trunc(title, 300) + ' | Loomio'

  $scope.$on 'pageError', (event, error) ->
    $scope.pageError = error

  $scope.keyDown = (event) -> KeyEventService.broadcast event

  $router.config([
    {path: '/dashboard', component: 'dashboardPage' },
    {path: '/inbox', component: 'inboxPage' },
    {path: '/groups', component: 'groupsPage' },
    {path: '/d/:key', component: 'threadPage' },
    {path: '/d/:key/:stub', component: 'threadPage' },
    {path: '/m/:key/', component: 'proposalRedirect' },
    {path: '/m/:key/:stub', component: 'proposalRedirect' },
    {path: '/m/:key/votes/new', component: 'proposalRedirect' },
    {path: '/g/new', component: 'groupForm' },
    {path: '/g/:parentKey/subgroups/new', component: 'groupForm'},
    {path: '/g/:key/edit', component: 'groupForm' },
    {path: '/g/:key/memberships', component: 'membershipsPage'}
    {path: '/g/:key', component: 'groupPage' },
    {path: '/g/:key/:stub', component: 'groupPage' },
  ]);

  return
