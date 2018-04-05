Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'
I18n     = require 'shared/services/i18n.coffee'

{ hardReload }    = require 'shared/helpers/window.coffee'
{ submitForm }    = require 'shared/helpers/form.coffee'
{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authComplete', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/complete/auth_complete.html'
  controller: ['$scope', ($scope) ->
    $scope.session = Records.sessions.build(email: $scope.user.email)
    $scope.attempts = 0

    $scope.submit = submitForm $scope, $scope.session,
      successCallback: -> hardReload()
      failureCallback: ->
        $scope.attempts += 1
        EventBus.emit $scope, 'doneProcessing'
      skipDoneProcessing: true

    submitOnEnter($scope, anyEnter: true)
  ]
