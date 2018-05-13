BaseModel = require 'shared/record_store/base_model'

module.exports = class IdentityModel extends BaseModel
  @singular: 'identity'
  @plural: 'identities'
