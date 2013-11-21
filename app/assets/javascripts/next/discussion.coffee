app = angular.module('loomioApp')

app.controller 'DiscussionController', ($scope, $routeParams, discussion) ->
  $scope.discussion = discussion

app.factory 'DiscussionSerivce', ->
  currentDiscussion: {}


app.directive 'activityFeed', ->
  # something for the activity feed..
