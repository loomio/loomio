angular.module('loomioApp').controller 'ThreadPageController', ($routeParams, $location, $rootScope, $document, $modal, Records, MessageChannelService, CurrentUser, DiscussionFormService) ->
  $rootScope.$broadcast('currentComponent', 'threadPage')

  Records.discussions.findOrFetchByKey($routeParams.key).then (discussion) =>
    @discussion = discussion
    Records.proposals.fetchByDiscussion @discussion
    Records.votes.fetchMyVotesByDiscussion @discussion
    @group = @discussion.group()
    $rootScope.$broadcast('viewingThread', @discussion)
    MessageChannelService.subscribeTo("/discussion-#{@discussion.key}", @onMessageReceived)

  @onMessageReceived = (event) ->
    console.log 'discussion update received', event

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editDiscussion = ->
    DiscussionFormService.openEditDiscussionModal(@discussion)

  @showContextMenu = =>
    @canEditDiscussion(@discussion)

  @canEditDiscussion = =>
    CurrentUser.canEditDiscussion(@discussion)

  console.log "hi"
  return
