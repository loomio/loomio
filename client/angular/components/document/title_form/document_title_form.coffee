Records = require 'shared/services/records.coffee'

{ submitForm }    = require 'angular/helpers/form.coffee'
{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'documentTitleForm', ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/title_form/document_title_form.html'
  controller: ($scope) ->
    $scope.submit = submitForm $scope, $scope.document,
      flashSuccess: "document.flash.success"
      successCallback: (data) ->
        $scope.$emit 'nextStep', Records.documents.find(data.documents[0].id)

    submitOnEnter($scope, anyEnter: true)
