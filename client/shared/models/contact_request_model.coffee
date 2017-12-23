BaseModel = require 'shared/models/base_model.coffee'

module.exports = class ContactRequestModel extends BaseModel
  @singular: 'contactRequest'
  @plural: 'contactRequests'

  defaultValues: ->
    message: ''
