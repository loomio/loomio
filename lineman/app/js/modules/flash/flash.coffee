angular.module('loomioApp').directive 'flash', ->
  scope: {modal: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/flash/flash.html'
  replace: true
  controller: 'FlashController'
