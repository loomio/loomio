angular.module('loomioApp').directive 'authSigninForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.back = ->
      $scope.user.email = ''

    $scope.magicLink = ->
      console.log("magic link", $scope.user.email)

    $scope.signIn = ->
      console.log("signing in", $scope.user.email, $scope.user.password)

    $scope.setPassword = ->
      console.log("setting password", $scope.user.email, $scope.user.password, $scope.user.passwordConfirm)
