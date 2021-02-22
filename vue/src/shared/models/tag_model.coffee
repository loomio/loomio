import BaseModel            from '@/shared/record_store/base_model.coffee'
import VuetifyColors  from 'vuetify/lib/util/colors'

colors = Object.keys(VuetifyColors).filter((name) -> name != 'shades').map (name) -> VuetifyColors[name]['base']

export default class TagModel extends BaseModel
  @singular: 'tag'
  @plural: 'tags'
  @uniqueIndices: ['id']
  @indices: ['groupId']
  @serializableAttributes: ['groupId', 'color', 'name']
  @colors: colors

  defaultValues: ->
    color: colors[Math.floor(Math.random() * colors.length)]

  relationships: ->
    @belongsTo 'group'
