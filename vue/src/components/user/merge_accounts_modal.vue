<script lang="coffee">
import Session        from '@/shared/services/session'
import Records from '@/shared/services/records'

export default
  props:
    close: Function
  data: ->
    targetEmail: ''
    emailChecked: false

  mounted: ->
    Records.users.removeExperience('show_vue_upgraded_modal')

  computed:
    isCurrentEmail: ->
      Session.user().email == @targetEmail

  methods:
    reset: ->
      @targetEmail = ''
      @emailChecked = false

    sendVerification: -> Records.users.sendMergeVerificationEmail(@targetEmail)

    checkEmailExistence: ->
      return if @isCurrentEmail
      Records.users.checkEmailExistence(@user.email).then (res) =>
        if res.exists
          @existingEmails = uniq(@existingEmails.concat([res.email]))
        if includes(@existingEmails, @user.email)
          @emailExists = true
          @isDisabled = true
        else
          @emailExists = false
          @isDisabled = false

</script>

<template lang="pug">
v-card
  v-card-text
    v-layout(column)
      h1.mb-8 Merge accounts
      div(v-if="!emailChecked")
        p Do you have another Loomio account you would like to merge this account with? Enter the email and we'll check to see the other account exists.
        p After that you'll need to verify that the email account is yours before we can proceed with the merge.
      div(v-else)
        p We've confirmed that the email address {{targetEmail}} belongs to another account.
        p Would you like to proceed with verifying {{targetEmail}} belongs to you?
    v-card-actions
      v-btn(v-if="emailChecked" block color="accent" @click="reset") Try another email address
      v-spacer
      v-btn.mt-4(v-if="!emailChecked" block color="accent" @click="checkEmailExistence") Check address
      v-btn.mt-4(v-else block color="primary") Verify address
</template>
