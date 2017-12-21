angular.module('loomioApp').factory 'ContactMessageRecordsInterface', (BaseRecordsInterface, ContactMessageModel) ->
  class ContactMessageRecordsInterface extends BaseRecordsInterface
    model: ContactMessageModel
