<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import { submitForm }   from '@/shared/helpers/form'

export default
  props:
    user: Object
    close: Function
  data: ->
    processing: false
    submit: null
  computed:
    actionName: -> if @user.hasPassword then 'password_changed' else 'password_set'
  created: ->
    @submit = submitForm @, @user,
      submitFn: Records.users.updateProfile
      flashSuccess: "change_password_form.#{@actionName}"
      successCallback: => @close()
</script>
<template lang="pug">
v-card.change-password-form.lmo-modal__narrow
  .lmo-disabled-form(v-show='processing')
  v-card-title
    .md-toolbar-tools.lmo-flex__space-between
      div
      h1.lmo-h1(v-if='user.hasPassword', v-t="'change_password_form.change_password_title'")
      h1.lmo-h1(v-if='!user.hasPassword', v-t="'change_password_form.set_password_title'")
      dismiss-modal-button(:close="close")
  v-card-text
    p.lmo-hint-text(v-if='user.hasPassword', v-t="'change_password_form.change_password_helptext'")
    p.lmo-hint-text(v-if='!user.hasPassword', v-t="'change_password_form.set_password_helptext'")
    .md-block.change-password-form__password-container
      label(v-t="'sign_up_form.password_label'")
      v-text-field.change-password-form__password(required='true', type='password', v-model='user.password')
      validation-errors(:subject='user', field='password')
    .md-block.change-password-form__password-confirmation-container
      label(v-t="'sign_up_form.password_confirmation_label'")
      v-text-field.change-password-form__password-confirmation(required='true', type='password', v-model='user.passwordConfirmation')
      validation-errors(:subject='user', field='passwordConfirmation')
  v-card-actions
    .lmo-md-actions
      v-btn.md-accent(ng-click='$close()', v-t="'common.action.cancel'")
      v-btn.md-primary.md-raised.change-password-form__submit(@click='submit()')
        span(v-if='user.hasPassword', v-t="'change_password_form.change_password'")
        span(v-if='!user.hasPassword', v-t="'change_password_form.set_password'")
</template>
<style lang="scss">
</style>
