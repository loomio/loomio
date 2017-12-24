Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'

{ listenForMentions } = require 'angular/helpers/mention.coffee'
{ listenForEmoji }    = require 'angular/helpers/emoji.coffee'
{ listenForPaste }    = require 'angular/helpers/document.coffee'

angular.module('loomioApp').directive 'lmoTextarea', ($compile) ->
  scope: {model: '=', field: '@', noAttachments: '@', label: '=?', placeholder: '=?', helptext: '=?', maxlength: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_textarea/lmo_textarea.html'
  replace: true
  controller: ($scope, $element) ->
    $scope.init = (model) ->
      $scope.model = model
      listenForMentions $scope, $scope.model
      listenForEmoji $scope, $scope.model, $scope.field, $element
      listenForPaste $scope
    $scope.init($scope.model)

    $scope.$on 'reinitializeForm', (_, model) ->
      $scope.init(model)

    $scope.modelLength = ->
      $element.find('textarea').val().length

    $scope.addDocument = ($mdMenu) ->
      $scope.$broadcast 'initializeDocument', Records.documents.buildFromModel($scope.model), $mdMenu

    $scope.$on 'nextStep', (_, doc) ->
      $scope.model.newDocumentIds.push doc.id

    $scope.$on 'documentAdded', (_, doc) ->
      $scope.model.newDocumentIds.push doc.id

    $scope.$on 'documentRemoved', (_, doc) ->
      $scope.model.removedDocumentIds.push doc.id
