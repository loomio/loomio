angular.module('loomioApp').directive 'authForm', (Records) ->
  scope: {preventClose: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ($scope) ->
    $scope.session = Records.sessions.build()
