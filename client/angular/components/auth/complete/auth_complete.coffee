Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'
I18n     = require 'shared/services/i18n'

{ hardReload }    = require 'shared/helpers/window'
{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

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
