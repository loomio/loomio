angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion, eventSubscription, EventService, RecordStoreService, FileUploadService, UserAuthService) ->
  $scope.discussion = discussion

  $scope.wrap = {}
  $scope.wrap.events = []
  nextPage = 1

  busy = false
  $scope.lastPage = false

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    console.log 'getting next page'
    busy = true
    EventService.fetch {discussion_id: discussion.id, page: nextPage}, (events) ->
      $scope.lastPage = true if events.length == 0
      $scope.wrap.events = discussion.events()
      nextPage = nextPage + 1
      busy = false

  $scope.getNextPage()

  eventReceived = (event) ->
    console.log('hey we gots da event')
    #$scope.$apply()

  EventService.subscribeTo(eventSubscription, eventReceived)

  $scope.safeEvent = (kind) ->
    _.contains ['new_comment', 'new_motion', 'new_vote'], kind

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)
