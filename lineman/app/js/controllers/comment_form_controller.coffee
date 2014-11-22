angular.module('loomioApp').controller 'CommentFormController', ($scope, CommentModel, CommentService, MembershipService, RecordStoreService) ->
  $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)
  group = $scope.discussion.group()
  $scope.mentionables = group.members()
  $scope.isExpanded = false

  $scope.expand = ->
    $scope.isExpanded = true
    $scope.$broadcast 'expandCommentField'

  $scope.collapse = (event) ->
    event.preventDefault()
    $scope.isExpanded = false
    $scope.$broadcast 'collapseCommentField'

  $scope.collapseIfEmpty = ->
    $scope.collapse() if $scope.comment.body.length == 0

  $scope.getMentionables = (fragment) ->
    MembershipService.fetchByNameFragment fragment, group.id, ->
      $scope.mentionables = _.filter(group.members(), (member) ->
        ~member.name.search(new RegExp(fragment, 'i')) or \
        ~member.label.search(new RegExp(fragment, 'i')))

  saveSuccess = ->
    $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)
    $scope.$emit('commentSaveSuccess')

  saveError = (error) ->
    console.log error

  $scope.submit = ->
    CommentService.save($scope.comment, saveSuccess, saveError)

  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id
    $scope.expand()