angular.module('loomioApp').directive 'pollCommonActionsDropdown', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/actions_dropdown/poll_common_actions_dropdown.html'
  controller: ($scope, AbilityService, ModalService, PollCommonShareModal, PollCommonFormModal, PollCommonCloseForm, PollCommonDeleteModal, PollCommonUnsubscribeModal) ->
    $scope.canSharePoll = ->
      AbilityService.canSharePoll($scope.poll)

    $scope.canEditPoll = ->
      AbilityService.canEditPoll($scope.poll)

    $scope.canClosePoll = ->
      AbilityService.canClosePoll($scope.poll)

    $scope.canDeletePoll = ->
      AbilityService.canDeletePoll($scope.poll)

    $scope.sharePoll = ->
      ModalService.open PollCommonShareModal, poll: -> $scope.poll

    $scope.editPoll = ->
      ModalService.open PollCommonFormModal, poll: -> $scope.poll

    $scope.closePoll = ->
      ModalService.open PollCommonCloseForm, poll: -> $scope.poll

    $scope.deletePoll = ->
      ModalService.open PollCommonDeleteModal, poll: -> $scope.poll

    $scope.toggleSubscription = ->
      ModalService.open PollCommonUnsubscribeModal, poll: -> $scope.poll
