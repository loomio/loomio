Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').directive 'documentUploadForm', ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/document/upload_form/document_upload_form.html'
  replace: true
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.percentComplete = 0

    EventBus.listen $scope, 'filesPasted', (_, files) -> $scope.upload(files)

    $scope.upload = (files) ->
      $scope.model.setErrors({})
      EventBus.emit $scope, 'processing'
      for file in files
        Records.documents.upload(file, $scope.progress)
                         .then($scope.success, $scope.failure)
                         .finally ->
                           EventBus.emit $scope, 'doneProcessing'
                           $scope.percentComplete = 0
                           $scope.$apply()

    $scope.selectFile = ->
      $element.find('input')[0].click()

    $scope.progress = (progress) ->
      return unless progress.total > 0
      $scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)
      $scope.$apply()

    $scope.abort = ->
      Records.documents.abort()

    $scope.success = (response) ->
      EventBus.emit $scope, 'documentAdded', Records.documents.find(response.documents[0].id)

    $scope.failure = (response) ->
      $scope.model.setErrors(response.data.errors)
  ]
