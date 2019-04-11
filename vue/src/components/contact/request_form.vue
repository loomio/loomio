<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import { submitForm }    from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

export default
  props:
    user: Object
  data: ->
    contactRequest: Records.contactRequests.build(recipientId: @user.id)
  created: ->
    @submit = submitForm @, @contactRequest,
      flashSuccess: "contact_request_form.email_sent"
      flashOptions: {name: @user.name}
      successCallback: ->
        EventBus.$emit '$close'
</script>
<template lang="pug">
.contact-user-form
  .md-block
    v-textarea.contact-request-form__message(v-model="contactRequest.message", maxlength="500", :label="$t('contact_request_form.message_placeholder')")
    validation-errors(:subject="contactRequest", field="message")

  .lmo-md-actions
    p(v-t="{ path: 'contact_request_form.helptext', args: { name: user.firstName() }}")
    v-btn.contact-request-form__submit(@click="submit()", v-t="'common.action.send'", primary, raised)
</template>
