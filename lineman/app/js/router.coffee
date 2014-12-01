angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when('/d/:key',
    templateUrl: 'generated/templates/discussion.html'
    controller: 'DiscussionController'
    resolve:
      discussion: (Records, $route) ->
        key = $route.current.params.key
        #Records.events.fetchByDiscussionKey(key)
        Records.discussions.findOrFetchByKey(key)

  ).when('/g/new',
    templateUrl: 'generated/templates/group_form.html',
    controller: 'GroupFormController',
    resolve:
      group: (Records, $route) ->
        groupKey = $route.current.params.id
        Records.groups.findOrFetchByKey(groupKey)
  ).when('/g/:key',
    templateUrl: 'generated/templates/group.html',
    controller: 'GroupController',
    resolve:
      group: (Records, $route) ->
        key = $route.current.params.key
        record = Records.groups.findOrFetchByKey(key)
        console.log 'promise?', record
        record
      groupKey: ($route) ->
        console.log 'router:', $route.current.params.id
        $route.current.params.id

  ).when('/g/:key/edit',
    templateUrl: 'generated/templates/group_form.html',
    controller: 'GroupFormController',
    resolve:
      group: (Records, $route) ->
        groupKey = $route.current.params.key
        Records.groups.findOrFetchByKey(groupKey)
  ).when('/g/:key/memberships',
    templateUrl: 'generated/templates/memberships_page.html',
    controller: 'MembershipsPageController',
    resolve:
      group: (Records, $route) ->
        groupKey = $route.current.params.key
        Records.groups.findOrFetchByKey(groupKey)
  ).when('/users/sign_in',
    templateUrl: 'generated/templates/login.html'
    controller: 'SessionController'
  ).when('/dashboard',
    templateUrl: 'generated/templates/dashboard.html'
    controller: 'DashboardController'
  ).when('/help',
    templateUrl: 'generated/templates/help_page.html'
  ).when('/contact',
    templateUrl: 'generated/templates/contact_page.html',
    controller: 'ContactPageController'
  ).when('/profile',
    templateUrl: 'generated/templates/profile_page.html',
    controller: 'ProfilePageController'
  ).otherwise
    redirectTo: window.Loomio.defaultRoute
