BaseModel = require 'shared/record_store/base_model.coffee'

module.exports = class IdentityModel extends BaseModel
  @singular: 'identity'
  @plural: 'identities'
