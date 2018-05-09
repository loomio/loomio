Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
AppConfig      = require 'shared/services/app_config'

{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'contactForm', ->
  templateUrl: 'generated/components/contact/form/contact_form.html'
  controller: ['$scope', ($scope) ->
    $scope.contactEmail = AppConfig.contactEmail

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()

    $scope.message = Records.contactMessages.build()
    if $scope.isLoggedIn()
      $scope.message.name = Session.user().name
      $scope.message.email = Session.user().email

    $scope.submit = submitForm $scope, $scope.message,
      flashSuccess: "contact_message_form.new_contact_message"
  ]
