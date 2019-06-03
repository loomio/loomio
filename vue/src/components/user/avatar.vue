<script lang="coffee">
import urlFor from '@/mixins/url_for'
import { is2x } from '@/shared/helpers/window'
import Gravatar from 'vue-gravatar';

export default
  components:
    'v-gravatar': Gravatar
  mixins: [urlFor]
  props:
    thread: Object
    user: Object
    coordinator: Boolean
    size: String
    noLink: Boolean
    colors: Object
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
    mdColors: ->
      colors = this.colors or {}
      if this.coordinator
        colors['border-color'] = 'primary-500'
      else if this.colors['border-color'] == 'primary-500'
        colors['border-color'] = 'grey-300'
      colors
    width: ->
      switch this.size
        when 'tiny'     then 20
        when 'small'    then 24
        when 'forty'    then 40
        when 'medium'   then 48
        when 'large'    then 64
        when 'featured' then 200
    gravatarSize: ->
      if is2x() then 2*@width else @width
    uploadedAvatarUrl: ->
      return unless this.user.avatarKind == 'uploaded'
      return this.user.avatarUrl if typeof this.user.avatarUrl is 'string'
      this.user.avatarUrl[this.imageSize]
    mdiSize: ->
      if @size == 'small' then 'mdi-18px' else 'mdi-24px'

    bgColor: ->
      @$vuetify.theme.accent

</script>

<template lang="pug">
v-avatar(v-if="user" :title='user.name' :size='width' :color="bgColor")
  v-gravatar(v-if="user.avatarKind === 'gravatar'", :hash='user.emailHash', :gravatar-size='gravatarSize', :alt='user.name')
  img(v-else-if="user.avatarKind === 'uploaded'", :alt='user.name', :src='uploadedAvatarUrl')
  span.body-1(v-else-if="user.avatarKind === 'initials'" :style="{width: width+'px'}") {{user.avatarInitials}}
  v-icon(v-else='', :class='[boxClass, mdiSize]') {{user.avatarKind}}
  //- // <div aria-hidden="true"  class="user-avatar" :class="[boxClass]">
  //- router-link(:to='urlFor(user)', v-if='!noLink')
  //-   user-avatar-body(:user='user', :coordinator='coordinator', :size='size', :colors='colors')
  //- user-avatar-body(v-if='noLink', :user='user', :coordinator='coordinator', :size='size', :colors='colors')
  //- div

</template>
