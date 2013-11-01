app = angular.module 'LoomioApp', ['ngRoute']

app.controller 'DiscussionController', ($scope, $http, $location, $routeParams) ->
  futureDiscussion = $http.get("/next/discussions/#{$routeParams.discussionId}")
  $scope.discussion = {
    author: {id: 1, name: 'Robert Guthrie', email: 'rguthrie@gmail.com'}

    comments: [
      {author_name: 'bill', body: 'hi there', created_at: new Date('2001-01-01 01:01:01')},
      {author_name: 'steve', body: 'gidday mate', created_at: new Date()}
    ]
  }
