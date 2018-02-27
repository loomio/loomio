Records  = require 'shared/services/records.coffee'

{ applySequence } = require 'shared/helpers/apply.coffee'
{ triggerResize } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'mediaForm', ->
  scope: {model: '='}
  templateUrl: 'generated/components/media/form/media_form.html'
  controller: ['$scope', ($scope) ->
    $scope.document = Records.documents.buildFromModel($scope.model)

    applySequence $scope,
      steps: ["choose", "record", "upload"]
      skipClose: true
      chooseComplete: (_, mediaType) ->
        $scope.document.mediaType = mediaType
        triggerResize()
      recordComplete: (_, blob) ->
        # store blob to document for upload. Save to s3?
   ]
