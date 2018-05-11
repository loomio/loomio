Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'contactRequestForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/contact_request/form/contact_request_form.html'
  controller: ['$scope', ($scope) ->

    $scope.contactRequest = Records.contactRequests.build(recipientId: $scope.user.id)

    $scope.submit = submitForm $scope, $scope.contactRequest,
      flashSuccess: "contact_request_form.email_sent"
      flashOptions: {name: $scope.user.name}
      successCallback: -> EventBus.emit $scope, '$close'

    submitOnEnter $scope
  ]
