Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'documentTitleForm', (FormService, ModalService, KeyEventService, ConfirmModal) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/title_form/document_title_form.html'
  controller: ($scope) ->
    $scope.submit = FormService.submit $scope, $scope.document,
      flashSuccess: "document.flash.success"
      successCallback: (data) ->
        $scope.$emit 'nextStep', Records.documents.find(data.documents[0].id)

    KeyEventService.submitOnEnter($scope, anyEnter: true)
