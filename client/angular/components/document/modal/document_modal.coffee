EventBus = require 'shared/services/event_bus'

{ listenForLoading } = require 'shared/helpers/listen'

angular.module('loomioApp').factory 'DocumentModal', ['$timeout', ($timeout) ->
  template: require('./document_modal.haml')
  controller: ['$scope', 'doc', ($scope, doc) ->
    $scope.document = doc.clone()
    listenForLoading $scope

    $timeout -> EventBus.emit $scope, 'initializeDocument', $scope.document
  ]
]
