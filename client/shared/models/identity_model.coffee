BaseModel = require 'shared/models/base_model'

module.exports = class IdentityModel extends BaseModel
  @singular: 'identity'
  @plural: 'identities'
