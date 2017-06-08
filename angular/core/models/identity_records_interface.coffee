angular.module('loomioApp').factory 'IdentityRecordsInterface', (BaseRecordsInterface, IdentityModel) ->
  class IdentityRecordsInterface extends BaseRecordsInterface
    model: IdentityModel

    performCommand: (id, command) ->
      @remote.getMember(id, command)
