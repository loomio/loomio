app = angular.module('loomioApp')

app.controller 'DiscussionController', ($scope, $routeParams, discussion) ->
  $scope.discussion = discussion
  $scope.comment = {}
  $scope.comment.discussion_id = discussion.id

app.directive 'activityFeed', ->
  # something for the activity feed..
