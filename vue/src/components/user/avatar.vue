<script lang="coffee">
import { is2x } from '@/shared/helpers/window'
import Gravatar from 'vue-gravatar';

export default
  components:
    'v-gravatar': Gravatar
  props:
    user: Object
    coordinator: Boolean
    size:
      type: [String, Number]
      default: 36
    noLink: Boolean
    colors: Object

  computed:
    width: ->
      if parseInt(@size)
        parseInt(@size)
      else
        switch @size
          when 'tiny'      then 20
          when 'small'     then 24
          when 'thirtysix' then 36
          when 'forty'     then 40
          when 'medium'    then 48
          when 'large'     then 64
          when 'featured'  then 200

    gravatarSize: ->
      if is2x() then 2*@width else @width

    uploadedAvatarUrl: ->
      return unless @user.avatarKind == 'uploaded'
      return @user.avatarUrl if typeof @user.avatarUrl is 'string'
      @user.avatarUrl[@imageSize]

    imageSize: ->
      if ['large', 'featured'].includes(@size) or is2x()
        'large'
      else
        'medium'

    componentType:  ->
      if @noLink
        'div'
      else
        'router-link'

</script>

<template lang="pug">
component.user-avatar(:is="componentType" :to="!noLink && urlFor(user)")
  v-avatar(:title='user.name' :size='width')
    v-gravatar(v-if="user.avatarKind === 'gravatar'" :hash='user.emailHash' :gravatar-size='gravatarSize' :alt='user.name')
    img(v-else-if="user.avatarKind === 'uploaded'" :alt='user.name' :src='uploadedAvatarUrl')
    span(v-else-if="user.avatarKind === 'initials'" :style="{width: width+'px'}") {{user.avatarInitials}}
    v-icon(v-else) {{user.avatarKind}}
</template>
