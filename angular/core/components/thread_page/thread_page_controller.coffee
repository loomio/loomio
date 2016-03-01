angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, Records, MessageChannelService, ModalService, DiscussionForm, MoveThreadForm, DeleteThreadForm, ScrollService, AbilityService, CurrentUser, ChangeThreadVolumeForm, TranslationService, RevisionHistoryModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage'})

  @activeProposalKey = $routeParams.proposal or $location.search().proposal
  @activeCommentId   = parseInt($routeParams.comment or $location.search().comment)

  handleCommentHash = do ->
    if match = $location.hash().match /comment-(\d+)/
      $location.search().comment = match[1]
      $location.hash('')

  @performScroll = ->
    ScrollService.scrollTo @elementToFocus(), 150
    $rootScope.$broadcast 'triggerVoteForm', $location.search().position if @openVoteModal()

  @openVoteModal = ->
    $location.search().position and
    @discussion.hasActiveProposal() and
    @discussion.activeProposal().key == $location.search().proposal and
    AbilityService.canVoteOn(@discussion.activeProposal())

  @elementToFocus = ->
    if @proposal
      "#proposal-#{@proposal.key}"
    else if @comment
      "#comment-#{@comment.id}"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @sequenceIdToFocus)
      '.activity-card__last-read-activity'
    else
      '.thread-context'

  @threadElementsLoaded = ->
    @eventsLoaded and @proposalsLoaded

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion
      @sequenceIdToFocus = @discussion.lastReadSequenceId # or location hash when we put it back in.

      $rootScope.$broadcast 'currentComponent', { page: 'threadPage'}
      $rootScope.$broadcast 'viewingThread', @discussion
      $rootScope.$broadcast 'setTitle', @discussion.title
      $rootScope.$broadcast 'analyticsSetGroup', @discussion.group()

  @init Records.discussions.find $routeParams.key
  Records.discussions.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  $scope.$on 'threadPageEventsLoaded',    (event) =>
    @eventsLoaded = true
    @comment = Records.comments.find(@activeCommentId) unless isNaN(@activeCommentId)
    @performScroll() if @proposalsLoaded or !@discussion.anyClosedProposals()
  $scope.$on 'threadPageProposalsLoaded', (event) =>
    @proposalsLoaded = true
    @proposal = Records.proposals.find(@activeProposalKey)
    $rootScope.$broadcast 'setSelectedProposal', @proposal
    @performScroll() if @eventsLoaded

  @group = ->
    @discussion.group()

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editThread = ->
    ModalService.open DiscussionForm, discussion: => @discussion

  @moveThread = ->
    ModalService.open MoveThreadForm, discussion: => @discussion

  @deleteThread = ->
    ModalService.open DeleteThreadForm, discussion: => @discussion

  @showContextMenu = =>
    @canEditThread(@discussion)

  @canStartProposal = ->
    AbilityService.canStartProposal(@discussion)

  @openChangeVolumeForm = ->
    ModalService.open ChangeThreadVolumeForm, thread: => @discussion

  @canChangeVolume = ->
    CurrentUser.isMemberOf(@discussion.group())

  @canEditThread = =>
    AbilityService.canEditThread(@discussion)

  @canMoveThread = =>
    AbilityService.canMoveThread(@discussion)

  @canDeleteThread = =>
    AbilityService.canDeleteThread(@discussion)

  @proposalInView = ($inview) ->
    $rootScope.$broadcast 'proposalInView', $inview

  @proposalButtonInView = ($inview) ->
    $rootScope.$broadcast 'proposalButtonInView', $inview

  @showRevisionHistory = ->
    ModalService.open RevisionHistoryModal, model: => @discussion

  TranslationService.listenForTranslations($scope, @)

  return
