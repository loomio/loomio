BaseModel = require 'shared/models/base_model'

module.exports = class ContactModel extends BaseModel
  @singular: 'contact'
  @plural: 'contacts'
