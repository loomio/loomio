angular.module('loomioApp').directive 'pollCommonUnsubscribeForm', (FormService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/unsubscribe/form/poll_common_unsubscribe_form.html'
  controller: ($scope) ->
    $scope.toggle = FormService.submit $scope, $scope.poll,
      submitFn: $scope.poll.toggleSubscription
      flashSuccess: ->
        if $scope.poll.subscribed
          'poll_common_unsubscribe_form.subscribed'
        else
          'poll_common_unsubscribe_form.unsubscribed'
