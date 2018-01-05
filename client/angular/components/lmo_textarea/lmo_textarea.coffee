Records      = require 'shared/services/records.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
ModalService = require 'shared/services/modal_service.coffee'

{ listenForMentions, listenForEmoji, listenForPaste } = require 'angular/helpers/listen.coffee'

angular.module('loomioApp').directive 'lmoTextarea', ['$compile', ($compile) ->
  scope: {model: '=', field: '@', noAttachments: '@', label: '=?', placeholder: '=?', helptext: '=?', maxlength: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_textarea/lmo_textarea.html'
  replace: true
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.init = (model) ->
      $scope.model = model
      listenForMentions $scope, $scope.model
      listenForEmoji $scope, $scope.model, $scope.field, $element
      listenForPaste $scope
    $scope.init($scope.model)

    EventBus.listen $scope, 'reinitializeForm', (_, model) ->
      $scope.init(model)

    $scope.modelLength = ->
      $element.find('textarea').val().length

    $scope.addDocument = ($mdMenu) ->
      EventBus.broadcast $scope, 'initializeDocument', Records.documents.buildFromModel($scope.model), $mdMenu

    EventBus.listen $scope, 'nextStep', (_, doc) ->
      $scope.model.newDocumentIds.push doc.id

    EventBus.listen $scope, 'documentAdded', (_, doc) ->
      $scope.model.newDocumentIds.push doc.id

    EventBus.listen $scope, 'documentRemoved', (_, doc) ->
      $scope.model.removedDocumentIds.push doc.id
  ]
]
