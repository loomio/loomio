angular.module('loomioApp').controller 'ThreadPageController', ($routeParams, $location, $rootScope, $document, $modal, Records, MessageChannelService, UserAuthService, DiscussionFormService) ->
  $rootScope.$broadcast('currentComponent', 'threadPage')

  @loading = true
  Records.discussions.findOrFetchByKey($routeParams.key).then (discussion) =>
    @loading = false
    console.log 'resolved discussion', discussion
    @discussion = discussion
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
    window.Loomio.currentUser.canEditDiscussion(@discussion)

  console.log "hi"
  return
