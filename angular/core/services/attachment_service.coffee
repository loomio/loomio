angular.module('loomioApp').factory 'AttachmentService', ->
  new class AttachmentService

    listenForAttachments: (scope, model) ->
      scope.$on 'disableAttachmentForm', -> scope.submitIsDisabled = true
      scope.$on 'enableAttachmentForm',  -> scope.submitIsDisabled = false
      scope.$on 'attachmentRemoved', (event, attachment) ->
        ids = model.newAttachmentIds
        ids.splice ids.indexOf(attachment.id), 1
        attachment.destroy() unless _.contains model.attachmentIds, attachment.id

    listenForPaste: (scope) ->
      scope.handlePaste = (event) ->
        data = event.clipboardData
        return unless item = _.first _.filter(data.items, (item) -> item.getAsFile())
        event.preventDefault()
        file = new File [item.getAsFile()], data.getData('text/plain'),
          lastModified: moment()
          type:         item.type
        scope.$broadcast 'attachmentPasted', file
