Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
AppConfig      = require 'shared/services/app_config'
UserHelpService= require 'shared/services/user_help_service'

{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'contactForm', ->
  template: require('./contact_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.submitted = false
    $scope.helpLink = UserHelpService.helpLink()

    $scope.contactEmail = AppConfig.contactEmail

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()

    $scope.message = Records.contactMessages.build()
    if $scope.isLoggedIn()
      $scope.message.name = Session.user().name
      $scope.message.email = Session.user().email
      $scope.message.userId = Session.user().id

    $scope.showContactConsent = AppConfig.features.app.show_contact_consent

    $scope.submit = submitForm $scope, $scope.message,
      flashSuccess: "contact_message_form.new_contact_message"
      successCallback: -> $scope.submitted = true
  ]
