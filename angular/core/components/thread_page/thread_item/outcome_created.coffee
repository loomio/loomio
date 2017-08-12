angular.module('loomioApp').directive 'outcomeCreated', ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/outcome_created.html'
  replace: true
