angular.module('loomioApp').factory 'CommunityModel', (BaseModel, AppConfig) ->
  class CommunityModel extends BaseModel
    @singular: 'community'
    @plural: 'communities'
    @serializableAttributes: AppConfig.permittedParams.community

    isLoomio: ->
      @communityType == 'loomio_group'

    defaultValues: ->
      customFields: {}

    relationships: ->
      @belongsTo 'poll'
      @belongsTo 'user'
      @belongsTo 'identity', from: 'identities'

    logo: ->
      if @isLoomio()
        "/img/default-logo-medium.png"
      else
        "/img/#{@communityType}-icon.svg"

    displayName: ->
      switch @communityType
        when 'facebook' then @customFields.facebook_group_name
        when 'slack'    then "#{@identity().customFields.slack_team_name} - ##{@customFields.slack_channel_name}"
        when 'loomio_group' then @recordStore.groups.find(@identifier).fullName
