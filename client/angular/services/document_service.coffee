Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'DocumentService', ->
  new class DocumentService

    listenForPaste: (scope) ->
      scope.handlePaste = (event) ->
        data = event.clipboardData
        return unless item = _.first _.filter(data.items, (item) -> item.getAsFile())
        event.preventDefault()
        file = new File [item.getAsFile()], data.getData('text/plain') || Date.now(),
          lastModified: moment()
          type:         item.type
        scope.$broadcast 'filesPasted', [file]
