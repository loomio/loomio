angular.module('loomioApp').directive 'authSignupForm', ->
  scope: {session: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.back = ->
      $scope.session.email = ''

    $scope.signUp = ->
      console.log("signing up", $scope.session.email, $scope.session.name)
