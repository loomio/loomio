angular.module('loomioApp').directive 'threadLintel', ->
  restrict: 'E'
  templateUrl: 'generated/components/thread_lintel/thread_lintel.html'
  replace: true
  controller: ($scope, Records, ModalService, ProposalForm, CurrentUser, ScrollService) ->
    $scope.show = ->
      $scope.scrolled && $scope.currentComponent == 'threadPage'

    $scope.scrollToThread = ->
      ScrollService.scrollTo 'h1:first'

    $scope.scrollToProposal = ->
      ScrollService.scrollTo 'section.current-proposal-card'

    $scope.canStartProposal = ->
      $scope.discussion && !$scope.discussion.hasActiveProposal() and CurrentUser.canStartProposals($scope.discussion)

    $scope.startProposal = ->
      ModalService.open ProposalForm, proposal: -> Records.proposals.initialize(discussion_id: $scope.discussion.id)

    $scope.$on 'currentComponent', (event, options) ->
      $scope.currentComponent = options['page']

    $scope.$on 'viewingThread', (event, discussion) ->
      $scope.discussion = discussion

    $scope.$on 'showThreadLintel', (event, bool) ->
      $scope.scrolled = bool

    $scope.$on 'threadPosition', (event, discussion, position) ->
      $scope.position = position
      $scope.discussion = discussion
      $scope.positionPercent = (position / discussion.lastSequenceId) *100

