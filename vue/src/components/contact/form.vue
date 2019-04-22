<style lang="scss">
.contact-form__helptext {
  margin-bottom: 48px;
}
</style>

<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import UserHelpService from '@/shared/services/user_help_service'

import { submitForm } from '@/shared/helpers/form'

export default
  data: ->
    submitted: false
    message: Records.contactMessages.build()
    isDisabled: false
  created: ->
    @helpLink = UserHelpService.helpLink()
    @contactEmail = AppConfig.contactEmail

    @submit = submitForm @, @message,
      flashSuccess: "contact_message_form.new_contact_message",
      successCallback: =>
        @submitted = true

    if @isLoggedIn
      @message.name = Session.user().name
      @message.email = Session.user().email
      @message.userId = Session.user().id
  computed:
    isLoggedIn: ->
      Session.isSignedIn()
</script>

<template>
      <div>
        <div v-show="!submitted" class="contact-form">
          <div v-show="isDisabled" class="lmo-disabled-form"></div>
          <h1 v-t="'contact_message_form.title'" class="lmo-h2"></h1>
          <p v-html="$t('contact_message_form.read_the_manual', { link: helpLink })"></p>
          <p>&nbsp;</p>
          <div md-input-container v-if="!isLoggedIn" class="md-block">
            <label v-t="'contact_message_form.name_label'"></label>
            <input type="text" :placeholder="$t('contact_message_form.name_placeholder')" v-model="message.name">
            <validation-errors :subject="message" field="name"></validation-errors>
          </div>
          <div md-input-container v-if="!isLoggedIn" class="md-block">
            <label v-t="'contact_message_form.email_label'"></label>
            <input type="text" :placeholder="$t('contact_message_form.email_placeholder')" v-model="message.email">
            <validation-errors :subject="message" field="email"></validation-errors>
          </div>
          <div md-input-container class="md-block">
            <label v-t="'contact_message_form.subject_label'"></label>
            <input type="text" :placeholder="$t('contact_message_form.subject_placeholder')" v-model="message.subject">
            <validation-errors :subject="message" field="subject"></validation-errors>
          </div>
          <div md-input-container class="md-block">
            <label v-t="'contact_message_form.message_label'"></label>
            <textarea v-model="message.message" :placeholder="$t('contact_message_form.message_placeholder')"></textarea>
            <validation-errors :subject="message" field="message"></validation-errors>
          </div>
          <p v-html="$t('contact_message_form.contact_us_email', { email: contactEmail })" class="lmo-hint-text"></p>
          <div class="lmo-md-actions">
            <div></div>
            <button md-button @click="submit" v-t="'contact_message_form.send_message'" class="md-primary md-raised"></button>
          </div>
        </div>
        <div v-show="submitted" class="contact-form__success">
          <h1 v-html="$t('contact_message_form.success', { name: message.name })" class="lmo-h2"></h1>
        </div>
      </div>
</template>
