<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    user: Object
  data: ->
    avatarUser: {}
  mounted: ->
    if !@user
      @user = { avatarKind: 'initials`' }
    if ['initials', 'mdi-email-outline'].includes(@user.avatarKind)
      @avatarUser = Records.users.build
        avatarKind: 'uploaded'
        avatarUrl:
          small: '/img/mascot.png'
          medium: '/img/mascot.png'
          large: '/img/mascot.png'
    else
      @avatarUser = @user
</script>
<template lang="pug">
.auth-avatar
  user-avatar.auth-avatar__avatar(:user='avatarUser', size='large', :no-link='true')
</template>
