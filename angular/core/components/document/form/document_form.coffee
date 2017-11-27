angular.module('loomioApp').directive 'documentForm', ($timeout, Records, SequenceService, FormService, KeyEventService) ->
  scope: {document: '=?', skipClose: '@'}
  templateUrl: 'generated/components/document/form/document_form.html'
  controller: ($scope) ->
    $scope.init = ->
      SequenceService.applySequence $scope,
        steps: ['method', 'url', 'title']
        skipClose: $scope.menu? # don't emit $close if we are in an md-menu
        initialStep: if $scope.document.isNew() then 'method' else 'title'
        methodComplete: (_, method) -> $scope.document.method = method
        urlComplete:    (_, url)    -> $scope.document.url    = url
        titleComplete:  (_, doc)    ->
          if $scope.menu
            $scope.menu.close()
            $scope.$emit 'documentAdded', doc
            # $scope.document = Records.documents.build()

    $scope.$on 'initializeDocument', (_, doc, $mdMenu) ->
      $scope.document = doc
      $scope.menu     = $mdMenu
      $scope.init()
      $timeout -> $scope.menu.open()

    $scope.init() if $scope.document
