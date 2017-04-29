angular.module('loomioApp').directive 'authSignupForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.back = ->
      $scope.user.email = ''

    $scope.signUp = ->
      console.log("signing up", $scope.user.email, $scope.user.name)
