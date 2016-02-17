angular.module('loomioApp').factory 'InvitationFormRecordsInterface', (BaseRecordsInterface, InvitationFormModel) ->
  class InvitationFormRecordsInterface extends BaseRecordsInterface
    model: InvitationFormModel
