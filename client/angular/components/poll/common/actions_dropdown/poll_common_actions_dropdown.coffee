AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
angular.module('loomioApp').directive 'pollCommonActionsDropdown', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/actions_dropdown/poll_common_actions_dropdown.html'
  controller: ['$scope', ($scope) ->
    $scope.canEditPoll = ->
      AbilityService.canEditPoll($scope.poll)

    $scope.canClosePoll = ->
      AbilityService.canClosePoll($scope.poll)

    $scope.canReopenPoll = ->
      AbilityService.canReopenPoll($scope.poll)

    $scope.canExportPoll = ->
      AbilityService.canExportPoll($scope.poll)

    $scope.canDeletePoll = ->
      AbilityService.canDeletePoll($scope.poll)

    $scope.exportPoll = ->
      exportPath = LmoUrlService.poll($scope.poll, {}, action:'export', absolute:true)
      LmoUrlService.goTo(exportPath,true)

    $scope.sharePoll = ->
      ModalService.open 'PollCommonShareModal', poll: -> $scope.poll

    $scope.editPoll = ->
      ModalService.open 'PollCommonEditModal', poll: -> $scope.poll

    $scope.closePoll = ->
      ModalService.open 'PollCommonCloseModal', poll: -> $scope.poll

    $scope.reopenPoll = ->
      ModalService.open 'PollCommonReopenModal', poll: -> $scope.poll

    $scope.deletePoll = ->
      ModalService.open 'PollCommonDeleteModal', poll: -> $scope.poll

    $scope.toggleSubscription = ->
      ModalService.open 'PollCommonUnsubscribeModal', poll: -> $scope.poll
  ]
