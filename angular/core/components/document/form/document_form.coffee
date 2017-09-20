angular.module('loomioApp').directive 'documentForm', (Records, FormService) ->
  scope: {model: '='}
  templateUrl: 'generated/components/document/form/document_form.html'
  controller: ($scope) ->
    $scope.document = Records.documents.build
      modelId:   $scope.model.id
      modelType: _.capitalize($scope.model.constructor.singular)

    $scope.$on 'attachmentUploaded', (_, attachment) ->
      $scope.document.url = attachment.context
      $scope.disabled = true

    $scope.submit = FormService.submit $scope, $scope.document,
      successFlash: "document.flash.success"

    $scope.$close = -> $scope.$emit '$close'
