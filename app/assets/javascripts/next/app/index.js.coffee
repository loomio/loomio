#app = angular.module 'LoomioApp', ['ngRoute']

#app.config ($routeProvider, $locationProvider) ->
  #$locationProvider.html5Mode(true)

  #$routeProvider.when '/discussions/:id',
    #templateUrl: '/assets/discussion.html'
    #controller: 'DiscussionController'
    #resolve:
      #discussionPromise: ($route, $http) ->
        #$http.get("/api/discussions/#{$route.current.params.id}")
  #.when '/',
    #templateUrl: '/assets/hello.html'
  #.otherwise
    #redirectTo: '/'

#app.controller 'DiscussionController', ($scope, $routeParams, discussionPromise) ->
  #$scope.discussion = discussionPromise.data

#app.controller 'AddCommentController', ($scope) ->
  #$scope.isExpanded = false
  #$scope.expand = ->
    #console.log 'expanding'
    #$scope.isExpanded = true
    #$('#expanded-input').focus()

  #$scope.collapse = ->
    #console.log 'collapsing'
    #$scope.isExpanded = false



