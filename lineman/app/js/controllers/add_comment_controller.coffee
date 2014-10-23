angular.module('loomioApp').controller 'AddCommentController', ($scope, CommentService) ->
  $scope.newComment =
    discussionId: $scope.discussion.id
    parentId: null
    body: ''
    attachments: []
    params: ->
      comment:
        discussion_id: $scope.discussion.id
        body: @body
        attachment_ids: _.pluck(@attachments, 'id')

  $scope.isExpanded = false

  $scope.expand = ->
    $scope.isExpanded = true

  $scope.collapseIfEmpty = ->
    if ($scope.newComment.body.length == 0)
      $scope.isExpanded = false

  $scope.processForm = () ->
    CommentService.add($scope.newComment.params(), $scope.success, $scope.error)

  $scope.$on 'showReplyToCommentForm', (event, originalComment) ->
    $scope.newComment.parentId = originalComment.id
    $scope.expand()

  $scope.success = ->
    $scope.newComment.body = ''
    $scope.newComment.attachments = []
    $scope.isExpanded = false

  $scope.error = (error) ->
    # show errors
    console.log error
