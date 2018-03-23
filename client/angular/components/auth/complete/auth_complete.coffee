Records = require 'shared/services/records.coffee'

{ hardReload } = require 'shared/helpers/window.coffee'
{ submitForm } = require 'shared/helpers/form.coffee'
{ registerKeyEvent } = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authComplete', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/complete/auth_complete.html'
  controller: ['$scope', ($scope) ->
    $scope.session = Records.sessions.build(email: $scope.user.email)
    $scope.attempts = 0

    $scope.submit = submitForm $scope, $scope.session,
      prepareFn:       -> $scope.session.code = $scope.code.join('')
      successCallback: -> hardReload()
      failureCallback: -> $scope.attempts += 1
  ]
