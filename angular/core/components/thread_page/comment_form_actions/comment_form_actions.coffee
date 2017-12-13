angular.module('loomioApp').directive 'commentFormActions', (KeyEventService) ->
  scope: {comment: '=', submit: '='}
  replace: true
  templateUrl: 'generated/components/thread_page/comment_form_actions/comment_form_actions.html'
  controller: ($scope) ->
    KeyEventService.submitOnEnter $scope
