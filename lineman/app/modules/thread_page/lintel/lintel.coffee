angular.module('loomioApp').directive 'lintel', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/thread_page/lintel/lintel.html'
  replace: true
