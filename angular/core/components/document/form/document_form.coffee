angular.module('loomioApp').directive 'documentForm', (Records, FormService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/form/document_form.html'
  controller: ($scope) ->
    $scope.model = Records.discussions.build()

    $scope.$on 'attachmentUploaded', (_, attachment) ->
      $scope.document.url = attachment.context
      $scope.disabled = true

    $scope.submit = FormService.submit $scope, $scope.document,
      successFlash: "document.flash.success"

    $scope.destroy = FormService.submit $scope, $scope.document,
      submitFn: $scope.document.destroy
      successCallback: -> Records.documents.find($scope.document.id).remove()
      successFlash: "document.flash.destroyed"

    $scope.$close = -> $scope.$emit '$close'
