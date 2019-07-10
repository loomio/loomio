import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import {isNumber, compact, map} from 'lodash'

export default class AnnouncementModel extends BaseModel
  @singular: 'announcement'
  @plural: 'announcements'

  defaultValues: ->
    recipients: []

  serialize: ->
    "#{@modelName()}_id": @model.id
    announcement:
      kind: @kind
      recipients:
        user_ids: compact map @recipients, (r) -> r.id    if isNumber(r.id)
        emails:   compact map @recipients, (r) -> r.email if r.email and !isNumber(r.email)


  modelName: ->
    @model.constructor.singular
