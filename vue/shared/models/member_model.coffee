BaseModel = require 'shared/record_store/base_model'

module.exports = class MemberModel extends BaseModel
  @singular: 'member'
  @plural: 'members'
  @serializableAttributes: ['key', 'title', 'subtitle', 'logo_type', 'logo_url', 'last_notified_at']

  afterConstruction: ->
    # munge member values so that they respond well to the %user_avatar directive
    @avatarKind = @logoType
    switch @avatarKind
      when 'gravatar' then @emailHash    = @logoUrl
      when 'initials' then @avatarInitials = @logoUrl
      when 'uploaded' then @avatarUrl      = { small: @logoUrl }
