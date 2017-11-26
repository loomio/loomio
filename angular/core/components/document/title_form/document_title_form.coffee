angular.module('loomioApp').directive 'documentTitleForm', (Records, FormService, ModalService, KeyEventService, ConfirmModal) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/title_form/document_title_form.html'
  controller: ($scope) ->
    $scope.submit = FormService.submit $scope, $scope.document,
      flashSuccess: "document.flash.success"
      successCallback: (data) ->
        $scope.$emit 'nextStep', Records.documents.find(data.documents[0].id)

    $scope.remove = ->
      ModalService.open ConfirmModal,
        forceSubmit: -> false
        submit:      -> Records.documents.find($scope.document.id).destroy
        text:        ->
          title:    'documents_page.confirm_remove_title'
          helptext: 'documents_page.confirm_remove_helptext'
          flash:    'documents_page.document_removed'


    KeyEventService.submitOnEnter($scope, anyEnter: true)
