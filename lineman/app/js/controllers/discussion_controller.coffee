angular.module('loomioApp').controller 'DiscussionController', ($scope, $routeParams, discussion) ->
  $scope.discussion = discussion
  $scope.comment = {}
  $scope.comment.discussion_id = discussion.id
