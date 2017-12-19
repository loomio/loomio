angular.module('loomioApp').factory 'RegistrationRecordsInterface', (BaseRecordsInterface, RegistrationModel) ->
  class RegistrationRecordsInterface extends BaseRecordsInterface
    model: RegistrationModel
