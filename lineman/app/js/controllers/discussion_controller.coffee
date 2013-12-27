angular.module('loomioApp').controller 'DiscussionController', ($scope, $routeParams, discussion) ->
  $scope.currentUser = discussion.current_user
  $scope.discussion = discussion
  $scope.newComment = {}
  $scope.newComment.discussion_id = discussion.id
