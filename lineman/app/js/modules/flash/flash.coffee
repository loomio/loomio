angular.module('loomioApp').directive 'flash', ->
  scope: {modal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/flash.html'
  replace: true
  controller: 'FlashController'
