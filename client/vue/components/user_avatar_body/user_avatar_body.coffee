{ is2x } = require 'shared/helpers/window'
LmoUrlService = require 'shared/services/lmo_url_service'

module.exports =
  props:
    user: Object
    coordinator: Boolean
    size: String
    colors: Object
  methods:
    urlFor: (model) -> LmoUrlService.route(model: model)
  computed:
    threadUrl: -> "/d/#{this.thread.key}"
    boxClass: -> "lmo-box--#{this.size}"
    userAvatarInitialsClass: -> "user-avatar__initials--#{this.size}"
    imageSize: ->
      switch this.size
        when 'small'
          if is2x() then 'medium' else 'small'
        when 'large', 'featured'
          'large'
        else
          if is2x() then 'large' else 'medium'
    mdiSize: -> if this.size == 'small' then 'mdi-18px' else 'mdi-24px'
    mdColors: ->
      colors = this.colors or {}
      if this.coordinator
        colors['border-color'] = 'primary-500'
      else if this.colors['border-color'] == 'primary-500'
        colors['border-color'] = 'grey-300'
      colors
    gravatarSize: ->
      size = switch this.size
        when 'small'    then 30
        when 'medium'   then 50
        when 'large'    then 80
        when 'featured' then 175
      if is2x() then 2*size else size
    uploadedAvatarUrl: ->
      return unless this.user.avatarKind == 'uploaded'
      return this.user.avatarUrl if typeof this.user.avatarUrl is 'string'
      this.user.avatarUrl[this.imageSize]

  template:
    """
    <div>
      <img v-if="user.avatarKind === 'gravatar'" class="user-avatar__img" :class="[boxClass]" :gravatar-src="user.emailHash" :gravatar-size="gravatarSize" :alt="user.name" />
      <img v-else-if="user.avatarKind === 'uploaded'" :class="`user-avatar__img lmo-box--${size}`" :alt="user.name" :src="uploadedAvatarUrl" />
      <div v-else-if="user.avatarKind === 'initials'" class="user-avatar__initials" :class="[boxClass, userAvatarInitialsClass]" aria-hidden="true">{{user.avatarInitials}}</div>
      <div v-else class="user-avatar__initials mdi lmo-flex--center lmo-flex__center lmo-flex__horizontal-center lmo-grey-on-white" :class="[boxClass, mdiSize, user.avatarKind]"></div>
    </div>
    """
