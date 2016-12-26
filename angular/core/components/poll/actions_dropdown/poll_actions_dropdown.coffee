angular.module('loomioApp').directive 'pollActionsDropdown', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/actions_dropdown/poll_actions_dropdown.html'
  controller: ($scope, AbilityService, PollService, ModalService, PollCloseForm) ->
    $scope.canEditPoll = ->
      AbilityService.canEditPoll($scope.poll)

    $scope.canClosePoll = ->
      AbilityService.canClosePoll($scope.poll)

    $scope.editPoll = ->
      ModalService.open PollService.formFor($scope.poll.pollType), poll: -> $scope.poll

    $scope.closePoll = ->
      ModalService.open PollCloseForm, poll: -> $scope.poll
