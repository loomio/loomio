BaseModel = require 'shared/models/base_model'

module.exports = class ContactRequestModel extends BaseModel
  @singular: 'contactRequest'
  @plural: 'contactRequests'

  defaultValues: ->
    message: ''
