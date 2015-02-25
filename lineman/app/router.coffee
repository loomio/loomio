angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  defaultRoute = if window? and window.Loomio?
    window.Loomio.defaultRoute
  else
    '/'

  $locationProvider.html5Mode(true)

  $routeProvider.when('/d/:key',
    templateUrl: 'generated/modules/discussion_page/discussion_page.html'
    controller: 'DiscussionPageController'
    resolve:
      discussion: (Records, $route) ->
        key = $route.current.params.key
        #Records.events.fetchByDiscussionKey(key)
        Records.discussions.findOrFetchByKey(key)

  ).when('/g/new',
    templateUrl: 'generated/modules/group_page/group_form.html',
    controller: 'GroupFormController',
    resolve:
      group: (Records, $route) ->
        groupKey = $route.current.params.id
        Records.groups.findOrFetchByKey(groupKey)
  ).when('/g/:key',
    templateUrl: 'generated/modules/group_page/group_page.html',
    controller: 'GroupController',
    resolve:
      group: (Records, $route) ->
        key = $route.current.params.key
        console.log 'key',  key
        Records.groups.findOrFetchByKey(key)
      groupKey: ($route) ->
        console.log 'router:', $route.current.params.id
        $route.current.params.id

  ).when('/g/:key/edit',
    templateUrl: 'generated/modules/group_page/group_form.html',
    controller: 'GroupFormController',
    resolve:
      group: (Records, $route) ->
        groupKey = $route.current.params.key
        Records.groups.findOrFetchByKey(groupKey)
  ).when('/g/:key/memberships',
    templateUrl: 'generated/modules/memberships_page/memberships_page.html',
    controller: 'MembershipsPageController',
    resolve:
      group: (Records, $route) ->
        groupKey = $route.current.params.key
        Records.groups.findOrFetchByKey(groupKey)
  ).when('/help',
    templateUrl: 'generated/modules/help_page/help_page.html'
  ).when('/contact',
    templateUrl: 'generated/modules/contact_page/contact_page.html',
    controller: 'ContactPageController'
  ).when('/profile',
    templateUrl: 'generated/modules/profile_page/profile_page.html',
    controller: 'ProfilePageController'
  ).otherwise
    redirectTo: defaultRoute
