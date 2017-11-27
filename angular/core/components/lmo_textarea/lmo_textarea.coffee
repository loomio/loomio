angular.module('loomioApp').directive 'lmoTextarea', ($compile, Records, EmojiService, ModalService, DocumentModal, AttachmentService, MentionService) ->
  scope: {model: '=', field: '@', noAttachments: '@', label: '=?', placeholder: '=?', helptext: '=?', maxlength: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_textarea/lmo_textarea.html'
  replace: true
  controller: ($scope, $element) ->
    $scope.init = (model) ->
      $scope.model = model
      EmojiService.listen $scope, $scope.model, $scope.field, $element
      MentionService.applyMentions $scope, $scope.model
      AttachmentService.listenForPaste $scope
    $scope.init($scope.model)

    $scope.$on 'reinitializeForm', (_, model) ->
      $scope.init(model)

    $scope.modelLength = ->
      $element.find('textarea').val().length

    $scope.addDocument = ($mdMenu) ->
      $scope.$broadcast 'initializeDocument', Records.documents.buildFromModel($scope.model), $mdMenu

    $scope.$on 'documentAdded', (_, doc) ->
      $scope.model.newDocumentIds.push doc.id

    $scope.$on 'documentRemoved', (_, doc) ->
      $scope.model.removedDocumentIds.push doc.id
