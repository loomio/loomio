angular.module('loomioApp').directive 'flash', ->
  scope: {modal: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/flash/flash.html'
  replace: true
  controller: 'FlashController'
