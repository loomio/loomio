angular.module('loomioApp').directive 'authEmailForm', (Records) ->
  scope: {session: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ($scope) ->
    $scope.save = ->
      $scope.$emit 'saveBegin'
      Records.sessions.emailStatus($scope.email).then (data) ->
        $scope.session.emailStatus = data.email_status
        $scope.session.hasPassword = data.has_password
        $scope.session.email       = $scope.email
      .finally -> $scope.$emit 'saveComplete'
