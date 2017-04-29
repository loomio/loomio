angular.module('loomioApp').directive 'authSigninForm', ->
  scope: {session: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.magicLink = ->
      console.log("magic link", $scope.session.email)

    $scope.signIn = ->
      console.log("signing in", $scope.session.email, $scope.session.password)
