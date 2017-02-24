angular.module('loomioApp').factory 'VisitorModel', (BaseModel) ->
  class VisitorModel extends BaseModel
    @singular: 'visitor'
    @plural: 'visitors'

    remind: =>
      @remote.postMember(@id, 'remind')
