angular.module('loomioApp').directive 'notifyChip', (ModalService, NotifyGroupModal) ->
  scope: {chip: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/chip/notify_chip.html'
  controller: ($scope) ->
    $scope.editChip = ->
      return unless $scope.chip.type == 'Group'
      ModalService.open NotifyGroupModal, groupId: -> $scope.chip.id
