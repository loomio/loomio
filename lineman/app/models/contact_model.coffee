angular.module('loomioApp').factory 'ContactModel', (BaseModel) ->
  class ContactMessageModel extends BaseModel
    @singular: 'contact'
    @plural: 'contacts'
