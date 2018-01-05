AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'
EventBus  = require 'shared/services/event_bus.coffee'
I18n      = require 'shared/services/i18n.coffee'

{ listenForPaste } = require 'angular/helpers/listen.coffee'
{ submitOnEnter }  = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'documentUrlForm', ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/url_form/document_url_form.html'
  controller: ['$scope', ($scope) ->
    $scope.model = Records.discussions.build()

    $scope.submit = ->
      $scope.model.setErrors({})
      if $scope.model.url.toString().match(AppConfig.regex.url.source)
        $scope.document.url = $scope.model.url
        EventBus.emit $scope, 'nextStep', $scope.document
      else
        $scope.model.setErrors(url: [I18n.t('document.error.invalid_format')])

    EventBus.listen $scope, 'documentAdded', (event, doc) ->
      event.stopPropagation()
      EventBus.emit $scope, 'nextStep', doc

    submitOnEnter $scope, anyEnter: true
    listenForPaste($scope)
  ]
