angular.module('loomioApp').controller 'NewCommentController', ($scope, $translate, $modal, CommentService, UserAuthService) ->

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

  $scope.editComment = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/edit_comment_form.html'
      controller: 'EditCommentFormController'
      resolve:
        comment: ->
          angular.copy($scope.comment)

  $scope.deleteComment = ->
    $modal.open
      templateUrl: 'generated/templates/delete_comment_form.html'
      controller: 'DeleteCommentFormController'
      resolve:
        comment: ->
          angular.copy($scope.comment)

  $scope.showContextMenu = ->
    $scope.canEditComment() or $scope.canDeleteComment()

  $scope.canEditComment = ->
    # should be:
    # currentUser.abilies().can('edit', $scope.comment)
    UserAuthService.currentUser.id == $scope.comment.authorId

  $scope.canDeleteComment = ->
    # should be:
    # currentUser.abilies().can('edit', $scope.comment)
    UserAuthService.currentUser.id == $scope.comment.authorId

  $scope.like = ->
    CommentService.like($scope.comment, renderLikedBySentence)

  $scope.unlike = ->
    CommentService.unlike($scope.comment, renderLikedBySentence)

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
