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
component.user-avatar(aria-hidden="true" :is="componentType" :to="!noLink && user.id && urlFor(user)" :style="{ 'width': width + 'px', margin: '0' }")
  v-avatar(:title='user.name' :size='width' :color="user.avatarUrl ? undefined : color")
    img(v-if="['gravatar', 'uploaded'].includes(user.avatarKind)" :alt='user.avatarInitials' :src='user.avatarUrl')
    span.user-avatar--initials(v-if="user.avatarKind === 'initials'" :style="{width: width+'px', height: width+'px'}") {{user.avatarInitials}}
    v-icon(v-if="!['initials', 'gravatar', 'uploaded'].includes(user.avatarKind)") {{user.avatarKind}}
</template>

<style lang="sass">
.user-avatar
  img
    // height: 100%
    width: auto
.user-avatar--initials
  color: rgba(0,0,0,.88)
  font-size: 15px
  display: flex
  align-items: center
  justify-content: center

</style>
