import BaseModel from '@/shared/record_store/base_model'

export default class ContactRequestModel extends BaseModel
  @singular: 'contactRequest'
  @plural: 'contactRequests'

  defaultValues: ->
    message: ''
