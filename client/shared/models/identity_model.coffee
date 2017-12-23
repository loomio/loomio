BaseModel = require 'shared/models/base_model.coffee'

module.exports = class IdentityModel extends BaseModel
  @singular: 'identity'
  @plural: 'identities'
