angular.module('loomioApp').directive 'authEmailForm', ($location, Records, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ($scope) ->
    $scope.email = $location.search().invitation_email

    $scope.submit = ->
      $scope.$emit 'saveBegin'
      Records.users.emailStatus($scope.email).then (data) ->
        _.merge $scope.user, Records.users.find(email: data.users[0].email)[0]
      .finally -> $scope.$emit 'saveComplete'


    document.querySelector('.auth-email-form__email input').focus()

    KeyEventService.submitOnEnter($scope, anyEnter: true)
