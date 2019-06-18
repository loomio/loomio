Records      = require 'shared/services/records'
ModalService = require 'shared/services/modal_service'
AbilityService = require 'shared/services/ability_service'

angular.module('loomioApp').directive 'documentCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/document/card/document_card.html'
  controller: ['$scope', ($scope) ->
    $scope.init = ->
      Records.documents.fetchByGroup($scope.group, null, per: 3).then (data) ->
        # we have to create a slightly wonky model to trick %document_list into
        # displaying all the documents across different models within our group.
        # this smells for sure, but don't want to change the way the list works
        # at the moment, because it works nicely in a lot of other places
        documents = Records.documents.find(_.map(data.documents, 'id'))
        $scope.model =
          isNew:                    -> true
          hasDocuments:             -> _.some(documents)
          newAndPersistedDocuments: -> documents
    $scope.init()

    $scope.canAddDocuments = ->
      AbilityService.canEditGroup($scope.group)

    $scope.addDocument = ->
      ModalService.open 'DocumentModal', doc: =>
        Records.documents.build
          modelId:   $scope.group.id
          modelType: 'Group'
  ]
