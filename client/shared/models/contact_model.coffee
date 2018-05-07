BaseModel = require 'shared/record_store/base_model'

module.exports = class ContactModel extends BaseModel
  @singular: 'contact'
  @plural: 'contacts'
