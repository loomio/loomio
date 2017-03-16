angular.module('loomioApp').factory 'VisitorModel', (AppConfig, BaseModel) ->
  class VisitorModel extends BaseModel
    @singular: 'visitor'
    @plural: 'visitors'
    @serializableAttributes: AppConfig.permittedParams.visitor

    remind: (poll) ->
      @processing = true
      @remote.postMember(@id, 'remind', { poll_id: poll.id }).finally =>
        @processing = false
