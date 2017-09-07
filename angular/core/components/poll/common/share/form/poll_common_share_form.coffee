angular.module('loomioApp').directive 'pollCommonShareForm', (Session, Records, AbilityService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/form/poll_common_share_form.html'
  controller: ($scope) ->

    $scope.hasPendingEmails = ->
      _.has($scope.poll, 'customFields.pending_emails.length') and
      $scope.poll.customFields.pending_emails.length > 0
