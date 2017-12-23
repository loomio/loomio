Records = require 'shared/services/records.coffee'

{ listenForMentions } = require 'angular/listeners/listen_for_mentions.coffee'
{ listenForEmoji }    = require 'angular/listeners/listen_for_emoji.coffee'
{ listenForPaste }    = require 'angular/listeners/listen_for_paste.coffee'

angular.module('loomioApp').directive 'lmoTextarea', ($compile, ModalService) ->
  scope: {model: '=', field: '@', noAttachments: '@', label: '=?', placeholder: '=?', helptext: '=?', maxlength: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_textarea/lmo_textarea.html'
  replace: true
  controller: ($scope, $element) ->
    $scope.init = (model) ->
      $scope.model = model
      listenForMentions $scope
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
