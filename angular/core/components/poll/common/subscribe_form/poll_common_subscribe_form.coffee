angular.module('loomioApp').directive 'pollCommonSubscribeForm', (FlashService) ->
  scope: {visitor: '='}
  templateUrl: 'generated/components/poll/common/subscribe_form/poll_common_subscribe_form.html'
  controller: ($scope) ->
    $scope.declineUpdates = ->
      $scope.$emit 'subscribeFormDismissed'

    $scope.validEmail = ->
      # TODO: actual email validation
      $scope.visitor.email?

    $scope.subscribe = ->
      $scope.visitor.save().then ->
        FlashService.success 'poll_common_subscribe_form.email_saved'
        $scope.$emit 'refreshStance'
