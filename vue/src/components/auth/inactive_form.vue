<script lang="coffee">
import AuthService from '@/shared/services/auth_service'

export default
  props:
    user: Object
  methods:
    reactivateUser: ->
      AuthService.reactivate(@user)
</script>
<template lang="pug">
.auth-inactive-form
  p.lmo-hint-text(v-t="{ path: 'auth_form.account_inactive', args: { email: user.email }}")
  v-btn.md-raised.md-primary.auth-inactive-form__submit.auth-inactive-form__reactivate(@click='reactivateUser()', v-t="'auth_form.reactivate'")
</template>
<style lang="scss">
</style>
