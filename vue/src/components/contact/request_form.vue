<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash  from '@/shared/services/flash'

export default
  props:
    user: Object
    close: Function
  data: ->
    contactRequest: Records.contactRequests.build(recipientId: @user.id)
  methods:
    submit: ->
      @contactRequest.save().then =>
        Flash.success "contact_request_form.email_sent", {name: @user.name}
        @close()

</script>
<template lang="pug">
v-card.contact-user-modal
  v-card-title
    h1.headline(v-t="{ path: 'contact_request_form.modal_title', args: { name: user.name }}")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.contact-user-form
    v-textarea.contact-request-form__message(v-model="contactRequest.message", maxlength="500", :label="$t('contact_request_form.message_placeholder')")
    validation-errors(:subject="contactRequest", field="message")
    p(v-t="{ path: 'contact_request_form.helptext', args: { name: user.firstName() }}")
  v-card-actions
    v-spacer
    v-btn.contact-request-form__submit(@click="submit()" v-t="'common.action.send'" color="primary")
</template>
