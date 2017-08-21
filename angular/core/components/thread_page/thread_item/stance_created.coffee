angular.module('loomioApp').directive 'stanceCreated', ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/stance_created.html'
  replace: true
