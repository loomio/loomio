angular.module('loomioApp').directive 'mediaUploadForm', ->
  scope: {document: '='}
  templateUrl: 'generated/components/media/upload_form/media_upload_form.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = ->
      console.log('wark')
  ]
