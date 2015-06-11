angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService) ->
    
    $scope.openModal = ->
      ModalService.openModal $scope.action
