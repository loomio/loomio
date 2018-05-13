EventBus = require 'shared/services/event_bus'

{ listenForLoading } = require 'shared/helpers/listen'

angular.module('loomioApp').factory 'DocumentModal', ['$timeout', ($timeout) ->
  templateUrl: 'generated/components/document/modal/document_modal.html'
  controller: ['$scope', 'doc', ($scope, doc) ->
    $scope.document = doc.clone()
    listenForLoading $scope

    $timeout -> EventBus.emit $scope, 'initializeDocument', $scope.document
  ]
]
