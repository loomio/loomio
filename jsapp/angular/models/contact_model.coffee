angular.module('loomioApp').factory 'ContactModel', (BaseModel) ->
  class ContactModel extends BaseModel
    @singular: 'contact'
    @plural: 'contacts'
