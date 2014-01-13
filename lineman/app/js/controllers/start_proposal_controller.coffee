angular.module('loomioApp').controller 'StartProposalController', ($scope, ProposalService) ->
  $scope.proposal =
    closing_at: moment().add('days', 3)
    discussion_id: $scope.discussion.id
    pie_chart_data: []

  $scope.showDatetimepicker = false
  $scope.isExpanded = false
  $scope.isHidden = $scope.discussion.active_proposal?
  $scope.isDisabled = false
  $scope.errorMessages = []

  $scope.openDatetimepicker = ->
    $scope.showDatetimepicker = true

  $scope.closeDatetimepicker = ->
    $scope.showDatetimepicker = false

  $scope.toggleDatetimepicker = ->
    $scope.showDatetimepicker = !$scope.showDatetimepicker

  $scope.showForm = ->
    $scope.isExpanded = true

  $scope.closeForm = ->
    $scope.isExpanded = false

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
    $scope.discussion.active_proposal = event.proposal

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

