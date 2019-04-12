import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class GroupIdentityModel extends BaseModel
  @singular: 'groupIdentity'
  @plural: 'groupIdentities'

  defaultValues: ->
    customFields: {}

  relationships: ->
    @belongsTo 'group'
    # @belongsTo 'identity'

  # because 'identity' is reserved
  userIdentity: ->
    _.head @recordStore.identities.find(id: @identityId)

  slackTeamName: ->
    @userIdentity().customFields.slack_team_name

  slackChannelName: ->
    @customFields.slack_channel_name
