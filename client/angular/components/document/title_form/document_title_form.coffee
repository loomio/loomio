Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'documentTitleForm', ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/title_form/document_title_form.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitForm $scope, $scope.document,
      flashSuccess: "document.flash.success"
      successCallback: (data) ->
        EventBus.emit $scope, 'nextStep', Records.documents.find(data.documents[0].id)

    submitOnEnter($scope, anyEnter: true)
  ]
