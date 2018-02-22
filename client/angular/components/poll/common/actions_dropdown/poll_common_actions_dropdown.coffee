AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'
angular.module('loomioApp').directive 'pollCommonActionsDropdown', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/actions_dropdown/poll_common_actions_dropdown.html'
  controller: ['$scope', ($scope) ->
    $scope.canSharePoll = ->
      AbilityService.canSharePoll($scope.poll)

    $scope.canEditPoll = ->
      AbilityService.canEditPoll($scope.poll)

    $scope.canClosePoll = ->
      AbilityService.canClosePoll($scope.poll)

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

    $scope.deletePoll = ->
      ModalService.open 'PollCommonDeleteModal', poll: -> $scope.poll

    $scope.toggleSubscription = ->
      ModalService.open 'PollCommonUnsubscribeModal', poll: -> $scope.poll
  ]
