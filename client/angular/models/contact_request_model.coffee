BaseModel    = require 'shared/models/base_model'

angular.module('loomioApp').factory 'ContactRequestModel', ->
  class ContactRequestModel extends BaseModel
    @singular: 'contactRequest'
    @plural: 'contactRequests'

    defaultValues: ->
      message: ''
