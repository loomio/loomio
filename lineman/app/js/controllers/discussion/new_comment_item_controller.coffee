angular.module('loomioApp').controller 'NewCommentItemController', ($scope, CommentService) ->
  $scope.comment = $scope.event.comment

  $scope.like = ->
    CommentService.like($scope.comment)

  $scope.unlike = ->
    CommentService.unlike($scope.comment)

  $scope.currentUserLikesIt = ->
    $scope.comment.liker_ids_and_names.hasOwnProperty($scope.currentUser.id)

  $scope.anybodyLikesIt = ->
    _.size($scope.comment.liker_ids_and_names) > 0

  $scope.whoLikesIt = ->
    names = _.without(_.values($scope.comment.liker_ids_and_names), $scope.currentUser.name)
    if $scope.currentUserLikesIt()
      names.push('You')
    names

  $scope.reply = ->
    $scope.$emit 'replyToCommentClicked', $scope.comment

  $scope.isAReply = ->
    _.isObject($scope.comment.parent)



