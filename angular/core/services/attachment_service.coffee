angular.module('loomioApp').factory 'AttachmentService', ->
  new class AttachmentService

    listenForPaste: (scope) ->
      scope.handlePaste = (event) ->
        data = event.clipboardData
        return unless item = _.first _.filter(data.items, (item) -> item.getAsFile())
        event.preventDefault()
        file = new File [item.getAsFile()], data.getData('text/plain'),
          lastModified: moment()
          type:         item.type
        scope.$broadcast 'attachmentPasted', file
