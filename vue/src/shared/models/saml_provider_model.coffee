import BaseModel            from '@/shared/record_store/base_model.coffee'
import { head } from 'lodash'

export default class SamlProviderModel extends BaseModel
  @singular: 'samlProvider'
  @plural: 'samlProviders'
  @uniqueIndices: ['id']
  @indices: ['groupId']
  @serializableAttributes: ['groupId', 'idpMetadataUrl']

  relationships: ->
    @belongsTo 'group'
