angular.module('loomioApp').factory 'AttachmentService', (Records) ->
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
        file = new File [item.getAsFile()], data.getData('text/plain') || Date.now(),
          lastModified: moment()
          type:         item.type
        scope.$broadcast 'attachmentPasted', file

    cleanupAfterUpdate: (model, singular) ->
      Records.attachments.find(attachableId: model.id, attachableType: _.capitalize(singular))
                         .filter (attachment) -> !_.contains(model.attachment_ids, attachment.id)
                         .map    (attachment) -> attachment.remove()
