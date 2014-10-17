angular.module('loomioApp').controller 'NewCommentItemController', ($scope, CommentService) ->
  $scope.comment = $scope.event.comment()

  $scope.like = ->
    CommentService.like($scope.comment)

  $scope.unlike = ->
    CommentService.unlike($scope.comment)

  $scope.currentUserLikesIt = ->
    _.contains($scope.comment.likerIds, $scope.currentUser.id)

  $scope.anybodyLikesIt = ->
    _.size($scope.comment.likerIds) > 0

  $scope.likedBySentence = ->
    otherIds = _.without($scope.comment.likerIds, $scope.currentUser.id)
    otherUsers = _.filter $scope.comment.likers(), (user) -> 
      _.contains(otherIds, user.id)

    names = _.first(otherUsers, 3)
    names.unshift('You') if $scope.currentUserLikesIt()

    result = names.join(', ')
    
    if $scope.comment.likerIds.length == 0
      suffix = ""
    else if !$scope.currentUserLikesIt() and otherIds.length == 1
      suffix = " likes this."
    else
      suffix = " like this."

    result + suffix

  $scope.reply = ->
    $scope.$emit 'replyToCommentClicked', $scope.comment

  $scope.isAReply = ->
    _.isObject($scope.comment.parent())

