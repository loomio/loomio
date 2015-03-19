angular.module('loomioApp').controller 'ThreadPageController', ($routeParams, $location, $rootScope, $document, $modal, Records, MessageChannelService, UserAuthService, DiscussionFormService) ->
  @loading = true
  Records.discussions.findOrFetchByKey($routeParams.key).then (discussion) =>
    @loading = false
    console.log 'resolved discussion', discussion
    @discussion = discussion
    @group = @discussion.group()
    $rootScope.$broadcast('viewingThread', @discussion)
    #MessageChannelService.subscribeTo("/discussion-#{@discussion.key}", onMessageReceived)

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editDiscussion = ->
    DiscussionFormService.openEditDiscussionModal(@discussion)

  @canStartProposals = =>
    !@discussion.hasActiveProposal() and window.Loomio.currentUser.canStartProposals(@discussion)

  @showContextMenu = =>
    @canEditDiscussion(@discussion)

  @canEditDiscussion = =>
    window.Loomio.currentUser.canEditDiscussion(@discussion)

  return
