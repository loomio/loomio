BaseModel    = require 'shared/models/base_model'

angular.module('loomioApp').factory 'IdentityModel', ->
  class IdentityModel extends BaseModel
    @singular: 'identity'
    @plural: 'identities'
