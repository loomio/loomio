angular.module('loomioApp').directive 'mediaRecordForm', ->
  scope: {document: '='}
  templateUrl: 'generated/components/media/record_form/media_record_form.html'
  controller: ['$scope', ($scope) ->
    $scope.start = ->
      $scope.recording = true
      # start recording

    $scope.stop = ->
      $scope.recording = false
      $scope.$broadcast 'nextStep',
      # stop recording
  ]
