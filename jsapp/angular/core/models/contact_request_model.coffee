angular.module('loomioApp').factory 'ContactRequestModel', (BaseModel) ->
  class ContactRequestModel extends BaseModel
    @singular: 'contactRequest'
    @plural: 'contactRequests'

    defaultValues: ->
      message: ''
