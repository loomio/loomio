<script lang="coffee">
import Records       from '@/shared/services/records'
import _includes from 'lodash/includes'

export default
  props:
    user: Object
  data: ->
    avatarUser: {}
  mounted: ->
    if !@user
      @user = { avatarKind: 'initials`' }
    if _includes(['initials', 'mdi-email-outline'], @user.avatarKind)
      @avatarUser = Records.users.build
        avatarKind:  'uploaded'
        avatarUrl:
          small:  '/img/mascot.png'

          medium: '/img/mascot.png'
          large:  '/img/mascot.png'
    else
      @avatarUser = @user
</script>
<template lang="pug">
.auth-avatar
  user-avatar.auth-avatar__avatar(:user='avatarUser', size='large', :no-link='true')
</template>
