Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ uploadForm } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'documentUploadForm', ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/document/upload_form/document_upload_form.html'
  replace: true
  controller: ['$scope', '$element', ($scope, $element) ->
    uploadForm $scope, $element, $scope.model,
      successCallback: (data) -> EventBus.emit $scope, 'documentAdded', Records.documents.find(data.documents[0].id)
      failureCallback: (data) -> $scope.model.setErrors(data.errors)
  ]
