angular.module('loomioApp').factory 'ContactModel', (BaseModel) ->
  class ContactModal extends BaseModel
    @singular: 'contact'
    @plural: 'contacts'
