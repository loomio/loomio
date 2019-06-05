<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import UserHelpService from '@/shared/services/user_help_service'
import EventBus from '@/shared/services/event_bus'

import { submitForm } from '@/shared/helpers/form'

export default
  data: ->
    submitted: false
    message: Records.contactMessages.build()
    isDisabled: false
    helpLink: UserHelpService.helpLink()
    contactEmail: AppConfig.contactEmail
    submit: null

  mounted: ->
    EventBus.$emit 'currentComponent',
      titleKey: 'contact_message_form.contact_us'
      page: 'inboxPage'

  created: ->
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

<template lang="pug">
v-container
  v-card.contact-page
    .contact-form(v-show='!submitted')
      .lmo-disabled-form(v-show='isDisabled')
      h1.lmo-h2(v-t="'contact_message_form.title'")
      p(v-html="$t('contact_message_form.read_the_manual', { link: helpLink })")
      p  
      .md-block(md-input-container='', v-if='!isLoggedIn')
        label(v-t="'contact_message_form.name_label'")
        input(type='text', :placeholder="$t('contact_message_form.name_placeholder')", v-model='message.name')
        validation-errors(:subject='message', field='name')
      .md-block(md-input-container='', v-if='!isLoggedIn')
        label(v-t="'contact_message_form.email_label'")
        input(type='text', :placeholder="$t('contact_message_form.email_placeholder')", v-model='message.email')
        validation-errors(:subject='message', field='email')
      .md-block(md-input-container='')
        label(v-t="'contact_message_form.subject_label'")
        input(type='text', :placeholder="$t('contact_message_form.subject_placeholder')", v-model='message.subject')
        validation-errors(:subject='message', field='subject')
      .md-block(md-input-container='')
        label(v-t="'contact_message_form.message_label'")
        textarea(v-model='message.message', :placeholder="$t('contact_message_form.message_placeholder')")
        validation-errors(:subject='message', field='message')
      p.lmo-hint-text(v-html="$t('contact_message_form.contact_us_email', { email: contactEmail })")
      .lmo-md-actions
        div
        button.md-primary.md-raised(md-button='', @click='submit', v-t="'contact_message_form.send_message'")
    .contact-form__success(v-show='submitted')
      h1.lmo-h2(v-html="$t('contact_message_form.success', { name: message.name })")
</template>

<style lang="scss">
</style>
