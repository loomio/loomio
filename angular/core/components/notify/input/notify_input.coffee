angular.module('loomioApp').directive 'notifyInput', (Records, ModalService, NotifyGroupModal) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/input/notify_input.html'
  controller: ($scope) ->
    $scope.search = (query) ->
      Records.searchResults.fetchNotified(query)

    $scope.edit = ($chip) ->
      ModalService.open(NotifyGroupModal, notified: -> $chip) if $chip.type == 'FormalGroup'
