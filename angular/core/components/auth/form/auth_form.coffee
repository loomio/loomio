angular.module('loomioApp').directive 'authForm', (Records) ->
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ($scope) ->
    $scope.session = Records.sessions.build()
