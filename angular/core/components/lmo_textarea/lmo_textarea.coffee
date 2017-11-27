angular.module('loomioApp').directive 'lmoTextarea', ($compile, Records, EmojiService, ModalService, DocumentModal, DocumentService, MentionService) ->
  scope: {model: '=', field: '@', noAttachments: '@', label: '=?', placeholder: '=?', helptext: '=?', maxlength: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_textarea/lmo_textarea.html'
  replace: true
  controller: ($scope, $element) ->
    $scope.init = (model) ->
      $scope.model = model
      EmojiService.listen $scope, $scope.model, $scope.field, $element
      MentionService.applyMentions $scope, $scope.model
      DocumentService.listenForPaste $scope
    $scope.init($scope.model)

    $scope.$on 'reinitializeForm', (_, model) ->
      $scope.init(model)

    $scope.modelLength = ->
      $element.find('textarea').val().length

    $scope.addDocument = ($mdMenu) ->
      $scope.$broadcast 'initializeDocument', Records.documents.buildFromModel($scope.model), $mdMenu

    $scope.$on 'fileUploaded', (_, file) ->
      Records.documents.build(
        url:   file.original,
        title: "#{file.filename}.#{file.filetype}"
      ).save().then (data) ->
        $scope.model.newDocumentIds.push data.documents[0].id

    $scope.$on 'documentAdded', (_, doc) ->
      $scope.model.newDocumentIds.push doc.id

    $scope.$on 'documentRemoved', (_, doc) ->
      $scope.model.removedDocumentIds.push doc.id
