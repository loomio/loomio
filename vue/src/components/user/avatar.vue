<script lang="coffee">
import { is2x } from '@/shared/helpers/window'
import Records from '@/shared/services/records'
import AppConfig from '@/shared/services/app_config'
import { pick } from 'lodash'

export default
  props:
    user:
      type: Object
      default: -> Records.users.build()

    coordinator: Boolean
    size:
      type: Number
      default: 36
    noLink: Boolean
    colors: Object

  computed:
    imageUrl: ->
      if @size > 64
        @user.avatarUrl
      else
        @user.thumbUrl

    color: ->
      colors = Object.values pick(AppConfig.theme.brand_colors, ['gold', 'sky', 'wellington', 'sunset'])
      colors[(@user.id || 0) % colors.length]

    componentType:  ->
      if @noLink or !@user.id
        'div'
      else
        'router-link'

</script>

<template lang="pug">
component.user-avatar(aria-hidden="true" :is="componentType" :to="!noLink && user.id && urlFor(user)" :style="{ 'width': size + 'px', margin: '0' }")
  v-avatar(:title='user.name' :size='size' :color="user.avatarUrl ? undefined : color")
    img(v-if="['gravatar', 'uploaded'].includes(user.avatarKind)" :alt='user.avatarInitials' :src='imageUrl')
    span.user-avatar--initials(v-if="user.avatarKind === 'initials'" :style="{width: size+'px', height: size+'px'}") {{user.avatarInitials}}
    v-icon(v-if="!['initials', 'gravatar', 'uploaded'].includes(user.avatarKind)") {{user.avatarKind}}
</template>

<style lang="sass">
.v-avatar
  img
    object-fit: cover
.user-avatar--initials
  color: rgba(0,0,0,.88)
  font-size: 15px
  display: flex
  align-items: center
  justify-content: center

</style>
