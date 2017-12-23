BaseModel = require 'shared/models/base_model.coffee'

module.exports = class ContactModel extends BaseModel
  @singular: 'contact'
  @plural: 'contacts'
