angular.module('loomioApp').factory 'ContactRequestRecordsInterface', (BaseRecordsInterface, ContactRequestModel) ->
  class ContactRequestRecordsInterface extends BaseRecordsInterface
    model: ContactRequestModel
