angular.module('loomioApp').directive 'documentList', (Records, AbilityService, ModalService, ConfirmModal, DocumentModal) ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/document/list/document_list.html'
  controller: ($scope) ->
    Records.documents.fetchByModel($scope.model)

    $scope.canEditDocuments = ->
      $scope.model.constructor.singular == 'Discussion' and
      AbilityService.canEditDocument($scope.model.group())

    $scope.edit = (doc) ->
      ModalService.open DocumentModal, doc: -> doc

    $scope.remove = (doc) ->
      ModalService.open ConfirmModal,
        forceSubmit: -> false
        submit:      -> doc.destroy
        text:        ->
          title:    'documents_page.confirm_remove_title'
          helptext: 'documents_page.confirm_remove_helptext'
          flash:    'documents_page.document_removed'
