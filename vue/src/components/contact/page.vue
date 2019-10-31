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
v-container.contact-page
  v-card.contact-form(v-show='!submitted')
    submit-overlay(:value='message.processing')
    v-card-title
      h1.headline(v-t="'contact_message_form.title'")
    v-card-text
      p(v-html="$t('contact_message_form.read_the_manual', { link: helpLink })")
      p
      div(v-if='!isLoggedIn')
        label(v-t="")
        v-text-field(:label="$t('contact_message_form.name_label')" :placeholder="$t('contact_message_form.name_placeholder')" v-model='message.name')
        validation-errors(:subject='message', field='name')
      div(v-if='!isLoggedIn')
        v-text-field(:label="$t('contact_message_form.email_label')" :placeholder="$t('contact_message_form.email_placeholder')", v-model='message.email')
        validation-errors(:subject='message', field='email')

      v-text-field(:label="$t('contact_message_form.subject_label')" :placeholder="$t('contact_message_form.subject_placeholder')", v-model='message.subject')
      validation-errors(:subject='message', field='subject')

      v-textarea(:label="$t('contact_message_form.message_label')" v-model='message.message', :placeholder="$t('contact_message_form.message_placeholder')")
      validation-errors(:subject='message', field='message')

      p.lmo-hint-text(v-html="$t('contact_message_form.contact_us_email', { email: contactEmail })")
      v-card-actions
        v-spacer
        v-btn(color="primary" @click='submit', v-t="'contact_message_form.send_message'")

  v-card.contact-form__success(v-show='submitted')
    v-card-title
      h1.headline(v-t="$t('contact_message_form.success', { name: message.name })")
</template>
