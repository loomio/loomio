angular.module('loomioApp').factory 'IdentityModel', (BaseModel) ->
  class IdentityModel extends BaseModel
    @singular: 'identity'
    @plural: 'identities'
