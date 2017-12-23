BaseModel    = require 'shared/models/base_model'

angular.module('loomioApp').factory 'ContactModel', ->
  class ContactModel extends BaseModel
    @singular: 'contact'
    @plural: 'contacts'
