Records      = require 'shared/services/records.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
ModalService = require 'shared/services/modal_service.coffee'

{ listenForMentions, listenForEmoji } = require 'shared/helpers/listen.coffee'
{ upload } = require 'shared/helpers/form.coffee'

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
    $scope.init($scope.model)

    EventBus.listen $scope, 'reinitializeForm', (_, model) ->
      $scope.init(model)

    EventBus.listen $scope, 'filesPasted', (event, files) ->
      return unless $element.find('textarea')[0] == document.activeElement
      $scope.upload(files)

    $scope.drop = (event) ->
      $scope.upload(event.dataTransfer.files)

    $scope.upload = upload $scope, $scope.model,
      successCallback: (res) ->
        $scope.model.newDocumentIds.push(res.documents[0].id)

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

    EventBus.listen $scope, 'focusTextarea', ->
      $element.find('textarea').focus()
  ]
]
