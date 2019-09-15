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

  created: ->
    @user.password = ''
    @user.passwordConfirmation = ''
    @submit = submitForm @, @user,
      submitFn: Records.users.updateProfile
      flashSuccess: "change_password_form.password_changed"
      successCallback: => @close()

</script>
<template lang="pug">
v-card.change-password-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()")
  .lmo-disabled-form(v-show='processing')
  v-card-title
    h1.headline(v-t="'change_password_form.set_password_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    p.lmo-hint-text(v-t="'change_password_form.set_password_helptext'")
    .change-password-form__password-container
      v-text-field.change-password-form__password(:label="$t('sign_up_form.password_label')" required type='password' v-model='user.password')
      validation-errors(:subject='user', field='password')
    .change-password-form__password-confirmation-container
      v-text-field.change-password-form__password-confirmation(:label="$t('sign_up_form.password_confirmation_label')" required='true' type='password' v-model='user.passwordConfirmation')
      validation-errors(:subject='user', field='passwordConfirmation')
  v-card-actions
    v-spacer
    v-btn.change-password-form__submit(color="primary" @click='submit()' v-t="'change_password_form.set_password'")
</template>
