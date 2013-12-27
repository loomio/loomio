angular.module('loomioApp').controller 'DiscussionController', ($scope, $routeParams, discussion) ->
  $scope.discussion = discussion
  $scope.new_comment = {}
  $scope.new_comment.discussion_id = discussion.id
