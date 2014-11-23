angular.module('loomioApp').controller 'DiscussionPageController', ($scope, $modal, discussion, MessageChannelService, EventService, RecordStoreService, FileUploadService, UserAuthService, ProposalModel) ->

  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/discussion-#{discussion.id}", onMessageReceived)
  #MessageChannelService.subscribeTo("/events", onMessageReceived)

  $scope.discussion = discussion

  $scope.wrap = {}
  nextPage = 1

  busy = false
  $scope.lastPage = false

  $scope.openProposalForm = ->
    $modal.open
      templateUrl: 'generated/templates/proposal_form.html'
      controller: 'ProposalFormController'
      resolve:
        proposal: ->
          new ProposalModel(discussion_id: $scope.discussion.id)

  $scope.openEditDiscussionForm = ->
    $modal.open
      templateUrl: 'generated/templates/discussion_form.html',
      controller: 'DiscussionFormController',
      resolve:
        discussion: ->
          angular.copy($scope.discussion)

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    EventService.fetch {discussion_id: discussion.id, page: nextPage}, (events) ->
      $scope.lastPage = true if events.length == 0
      nextPage = nextPage + 1
      busy = false

  $scope.getNextPage()

  $scope.safeEvent = (kind) ->
    _.contains ['new_comment', 'new_motion', 'new_vote'], kind

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)
