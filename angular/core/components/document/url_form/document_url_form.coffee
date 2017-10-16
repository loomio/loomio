angular.module('loomioApp').directive 'documentUrlForm', (Records, FormService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/url_form/document_url_form.html'
  controller: ($scope) ->
    $scope.model = Records.discussions.build()

    $scope.$on 'attachmentUploaded', (_, attachment) ->
      $scope.document.url   = attachment.context
      $scope.document.title = $scope.document.title || attachment.filename

    $scope.toggleForm = ->
      $scope.enteringUrl = !$scope.enteringUrl

    $scope.next = ->
      $scope.document.url = $scope.newUrl

    KeyEventService.submitOnEnter $scope, anyEnter: true
