angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when('/discussions/:id',
    templateUrl: 'generated/templates/discussion.html'
    controller: 'DiscussionController'
    resolve:
      discussion: ($route, DiscussionService, RecordStoreService) ->
        promise = DiscussionService.fetchByKey($route.current.params.id)
        if discussion = RecordStoreService.get('discussions', $route.current.params.id)
          discussion
        else
          promise
      currentUser: ($http, UserAuthService) ->
        UserAuthService.fetchCurrentUser()
  ).when('/groups/new',
    templateUrl: 'generated/templates/group_form.html',
    controller: 'GroupFormController',
    resolve:
      group: ($route, GroupService, GroupModel, RecordStoreService) ->
        GroupService.fetchByKey($route.current.params.parent_id).then(->
          new GroupModel(parent_id: RecordStoreService.get('groups', $route.current.params.parent_id).id))
  ).when('/groups/:id',
    templateUrl: 'generated/templates/group.html',
    controller: 'GroupController',
    resolve:
      group: ($route, GroupService) ->
        GroupService.fetchByKey($route.current.params.id)
      currentUser: ($http, UserAuthService) ->
        UserAuthService.fetchCurrentUser()
  ).when('/groups/:id/edit',
    templateUrl: 'generated/templates/group_form.html',
    controller: 'GroupFormController',
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
    redirectTo: '/'
