angular.module('loomioApp').directive 'flash', ->
  scope: {modal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/flash/flash.html'
  replace: true
  controller: 'FlashController'
