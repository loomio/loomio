import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class GroupSurveyModel extends BaseModel
  @singular: 'group_survey'
  @plural: 'group_surveys'
  @indices: ['groupId']

  relationships: ->
    @belongsTo 'group'
