angular.module('loomioApp').directive 'threadLintel', ->
  restrict: 'E'
  templateUrl: 'generated/components/thread_lintel/thread_lintel.html'
  replace: true
  controller: ($scope, Records, ModalService, ProposalForm) ->
    $scope.show = ->
      $scope.scrolled && $scope.currentComponent == 'threadPage'

    $scope.canStartProposal = ->
      true

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

