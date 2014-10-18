angular.module('loomioApp').controller 'NewCommentItemController', ($scope, CommentService) ->
  $scope.comment = $scope.event.comment()

  $scope.like = ->
    CommentService.like($scope.comment)

  $scope.unlike = ->
    CommentService.unlike($scope.comment)

  $scope.currentUserLikesIt = ->
    _.contains($scope.comment.likerIds, $scope.currentUser.id)

  $scope.anybodyLikesIt = ->
    $scope.comment.likerIds.length > 0

  $scope.likedBySentence = ->
    num_likers = $scope.comment.likers().length

    if num_likers == 0
      ''
    else if num_likers == 1
      if $scope.currentUserLikesIt()
        "You like this."
      else
        "Liked by #{$scope.comment.likers()[0].name}."
    else
      otherIds = _.without($scope.comment.likerIds, $scope.currentUser.id)
      otherUsers = _.filter $scope.comment.likers(), (user) ->
        _.contains(otherIds, user.id)

      names = _.map otherUsers, (user) ->
        user.name

      names.unshift('You') if $scope.currentUserLikesIt()
      if names.length == 2
        "Liked by " + names.join(' and ') + '.'
      else
        "Liked by " + names.slice(0, -1).join(', ') + ' and ' + names.splice(-1) + "."

  $scope.reply = ->
    $scope.$emit 'replyToCommentClicked', $scope.comment

  $scope.isAReply = ->
    _.isObject($scope.comment.parent())

