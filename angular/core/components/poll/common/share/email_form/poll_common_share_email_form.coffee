angular.module('loomioApp').directive 'pollCommonShareEmailForm', (KeyEventService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/email_form/poll_common_share_email_form.html'
  controller: ($scope) ->
    $scope.newEmail = ''

    $scope.add = ->
      if $scope.newEmail.length <= 0
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_empty')
      else if _.contains($scope.poll.customFields.pending_emails, $scope.newEmail)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_exists', email: $scope.newEmail)
      else if !$scope.newEmail.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_invalid')
      else
        $scope.emailValidationError = null
        $scope.poll.customFields.pending_emails.push($scope.newEmail)
        $scope.newEmail = ''

    $scope.remove = (email) ->
      _.pull($scope.poll.customFields.pending_emails, email)

    $scope.submit = ->
      $scope.add()
      $scope.poll.createVisitors()

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.add, (active) ->
      active.classList.contains('poll-common-share-form__add-option-input')
