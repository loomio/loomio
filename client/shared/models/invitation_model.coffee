BaseModel = require 'shared/models/base_model'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class InvitationModel extends BaseModel
  @singular: 'invitation'
  @plural: 'invitations'
  @indices: ['groupId']
  @serializableAttributes: AppConfig.permittedParams.invitation
  @draftPayloadAttributes: ['emails', 'message']

  relationships: ->
    @belongsTo 'group'

  isPending: ->
    !@cancelledAt? && !@acceptedAt?

  resend: ->
    @remote.postMember(@id, 'resend').then => @reminded = true
