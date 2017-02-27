angular.module('loomioApp').factory 'VisitorModel', (BaseModel) ->
  class VisitorModel extends BaseModel
    @singular: 'visitor'
    @plural: 'visitors'

    remind: (poll) =>
      @remote.postMember(@id, 'remind', {poll_id: poll.key})
