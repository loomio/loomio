angular.module('loomioApp').controller 'NewCommentItemController', ($scope, $translate, $modal, Records, UserAuthService) ->
  renderLikedBySentence = ->
    otherIds = _.without($scope.comment.likerIds, UserAuthService.currentUser.id)
    otherUsers = _.filter $scope.comment.likers(), (user) -> _.contains(otherIds, user.id)
    otherNames = _.map otherUsers, (user) -> user.name

    if $scope.currentUserLikesIt()
      switch otherNames.length
        when 0
          # You like this.
          $translate('discussion.you_like_this').then updateLikedBySentence
        when 1
          # liked by you and Rebeka.
          $translate('discussion.liked_by_you_and_someone',
                     name: otherNames[0]).then updateLikedBySentence
        else
          # liked by you, Rebeka and Joshua.
          joinedNames = otherNames.slice(0, -1).join(', ')
          name = otherNames.slice(-1)[0]
          $translate('discussion.liked_by_you_and_others',
                     joinedNames: joinedNames, name: name).then updateLikedBySentence
    else
      switch otherNames.length
        when 0
          ''
        when 1
          # Liked by Rebeka.
          $translate('discussion.liked_by_someone', name: otherNames[0]).then updateLikedBySentence
        when 2
          # Liked by Rebeka and Joshua.
          $translate('discussion.liked_by_two_others', name_1: otherNames[0], name_2: otherNames[1]).then updateLikedBySentence
        else
          # Liked by Rebeka, Someone and Joshua
          joinedNames = otherNames.slice(0, -1).join(', ')
          name = otherNames.slice(-1)[0]
          $translate('discussion.liked_by_many_others', joinedNames: joinedNames, name: name).then updateLikedBySentence

  $scope.comment = $scope.event.comment()

  $scope.editComment = ->
    modalInstance = $modal.open
      templateUrl: 'generated/modules/discussion_page/comment_form/edit_comment.html'
      controller: 'EditCommentController'
      resolve:
        comment: -> angular.copy($scope.comment)

  $scope.deleteComment = ->
    modalInstance = $modal.open
      templateUrl: 'generated/modules/discussion_page/comment_form/delete_comment.html'
      controller: 'DeleteCommentController'
      resolve:
        comment: -> angular.copy($scope.comment)

  $scope.showContextMenu = ->
    $scope.canEditComment($scope.comment) or $scope.canDeleteComment($scope.comment)

  $scope.canEditComment = ->
    UserAuthService.currentUser.canEditComment($scope.comment)

  $scope.canDeleteComment = ->
    UserAuthService.currentUser.canDeleteComment($scope.comment)

  $scope.like = ->
    Records.comments.like(UserAuthService.currentUser, $scope.comment, renderLikedBySentence)

  $scope.unlike = ->
    Records.comments.unlike(UserAuthService.currentUser, $scope.comment, renderLikedBySentence)

  $scope.currentUserLikesIt = ->
    _.contains($scope.comment.likerIds, UserAuthService.currentUser.id)

  $scope.anybodyLikesIt = ->
    $scope.comment.likerIds.length > 0

  $scope.likedBySentence = ''

  updateLikedBySentence = (sentence) ->
    $scope.likedBySentence = sentence

  $scope.$watch 'comment.likerIds', ->
    renderLikedBySentence()

  $scope.reply = ->
    $scope.$emit 'replyToCommentClicked', $scope.comment
