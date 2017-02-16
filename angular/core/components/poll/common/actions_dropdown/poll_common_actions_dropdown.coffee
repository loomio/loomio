angular.module('loomioApp').directive 'pollCommonActionsDropdown', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/actions_dropdown/poll_common_actions_dropdown.html'
  controller: ($scope, AbilityService, PollService, ModalService, PollCommonFormModal, PollCommonCloseForm) ->
    $scope.canEditPoll = ->
      AbilityService.canEditPoll($scope.poll)

    $scope.canClosePoll = ->
      AbilityService.canClosePoll($scope.poll)

    $scope.editPoll = ->
      ModalService.open PollCommonFormModal, poll: -> $scope.poll

    $scope.closePoll = ->
      ModalService.open PollCommonCloseForm, poll: -> $scope.poll
