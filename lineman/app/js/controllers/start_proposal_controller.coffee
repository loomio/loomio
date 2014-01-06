angular.module('loomioApp').controller 'StartProposalController', ($scope, ProposalService) ->
  $scope.proposal =
    closing_at: moment().add('days', 3)
    discussion_id: $scope.discussion.id

  $scope.showDatetimepicker = false

  $scope.openDatetimepicker = ->
    $scope.showDatetimepicker = true

  $scope.closeDatetimepicker = ->
    $scope.showDatetimepicker = false

  $scope.toggleDatetimepicker = ->
    $scope.showDatetimepicker = !$scope.showDatetimepicker

  $scope.isExpanded = false

  $scope.isHidden = false

  $scope.isDisabled = false
  $scope.errorMessages = []

  $scope.showForm = ->
    $scope.isExpanded = true

  $scope.collapseIfEmpty = ->
    if ($scope.commentField.val().length == 0)
      $scope.isExpanded = false

  $scope.submitProposal = ->
    $scope.isDisabled = true
    ProposalService.create($scope.proposal, $scope.saveSuccess, $scope.saveError)

  $scope.saveSuccess = (event) ->
    $scope.discussion.events.push(event)
    $scope.isHidden = true
    $scope.isDisabled = false
    $scope.discussion.proposal = event.eventable

  $scope.saveError = (errors) ->
    $scope.isDisabled = false
    $scope.errorMessages = errors

