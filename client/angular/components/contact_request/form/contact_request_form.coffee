Records = require 'shared/services/records.coffee'

{ submitForm }    = require 'angular/helpers/form.coffee'
{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'contactRequestForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/contact_request/form/contact_request_form.html'
  controller: ['$scope', ($scope) ->

    $scope.contactRequest = Records.contactRequests.build(recipientId: $scope.user.id)

    $scope.submit = submitForm $scope, $scope.contactRequest,
      flashSuccess: "contact_request_form.email_sent"
      flashOptions: {name: $scope.user.name}
      successCallback: -> $scope.$emit '$close'

    submitOnEnter $scope
  ]
