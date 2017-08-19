angular.module('loomioApp').directive 'eventChildren', () ->
  scope: {parent: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/event_children/event_children.html'
  replace: true
