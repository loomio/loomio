angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when('/d/:id',
    templateUrl: 'generated/templates/discussion.html'
    controller: 'DiscussionController'
    resolve:
      discussion: ($route, DiscussionService) ->
        DiscussionService.fetchByKey($route.current.params.id)
      currentUser: ($http, UserAuthService) ->
        UserAuthService.fetchCurrentUser()
  ).when('/g/new',
    templateUrl: 'generated/templates/group_form.html',
    controller: 'GroupFormController',
    resolve:
      group: ($route, GroupService, GroupModel, Records) ->
        GroupService.fetchByKey($route.current.params.parent_id).then (group) ->
          Records.groups.new(parent_id: group.id)
  ).when('/g/:id',
    templateUrl: 'generated/templates/group.html',
    controller: 'GroupController',
    resolve:
      group: ($route, GroupService) ->
        console.log 'resolving group'
        GroupService.fetchByKey($route.current.params.id)
      currentUser: ($http, UserAuthService) ->
        UserAuthService.fetchCurrentUser()
  ).when('/g/:id/edit',
    templateUrl: 'generated/templates/group_form.html',
    controller: 'GroupFormController',
    resolve:
      group: ($route, GroupService) ->
        GroupService.fetchByKey($route.current.params.id)
      currentUser: ($http, UserAuthService) ->
        UserAuthService.fetchCurrentUser()
  ).when('/g/:id/memberships',
    templateUrl: 'generated/templates/memberships_page.html',
    controller: 'MembershipsPageController',
    resolve:
      group: ($route, GroupService) ->
        GroupService.fetchByKey($route.current.params.id)
      currentUser: ($http, UserAuthService) ->
        UserAuthService.fetchCurrentUser()
  ).when('/users/sign_in',
    templateUrl: 'generated/templates/login.html'
    controller: 'SessionController'
  ).when('/dashboard',
    templateUrl: 'generated/templates/dashboard.html'
    controller: 'DashboardController'
  ).otherwise
    redirectTo: '/g/WmPCB3IR'
