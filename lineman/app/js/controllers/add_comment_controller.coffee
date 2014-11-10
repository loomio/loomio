angular.module('loomioApp').controller 'AddCommentController', ($scope, CommentModel, CommentService, UserModel, UserService) ->
  $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)

  $scope.isExpanded = false

  $scope.mentionables = []  
  $scope.fragment = ''

  # (We don't speak of the unmentionables.)
  $scope.getMentionables = (fragment) ->
    UserService.fetchByNameFragment fragment, $scope.discussion.groupId, (response) ->
      $scope.mentionables = _.map response, (data) -> new UserModel(data)

  $scope.applyMention = (user) ->
    console.log 'hi!'
    

  $scope.expand = ->
    $scope.isExpanded = true
    $scope.$broadcast 'expandCommentField'

  $scope.collapseIfEmpty = ->
    if ($scope.comment.body.length == 0)
      $scope.isExpanded = false

  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id
    $scope.expand()

