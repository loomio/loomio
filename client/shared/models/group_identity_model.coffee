BaseModel = require 'shared/models/base_model.coffee'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class GroupIdentityModel extends BaseModel
  @singular: 'groupIdentity'
  @plural: 'groupIdentities'
  @serializableAttributes: AppConfig.permittedParams.groupIdentity

  defaultValues: ->
    customFields: {}

  relationships: ->
    @belongsTo 'group'
    # @belongsTo 'identity'

  # because 'identity' is reserved
  userIdentity: ->
    _.first @recordStore.identities.find(id: @identityId)

  slackTeamName: ->
    @userIdentity().customFields.slack_team_name

  slackChannelName: ->
    @customFields.slack_channel_name
