<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash  from '@/shared/services/flash';

export default
{
  props: {
    user: Object
  },
  data() {
    return {contactRequest: Records.contactRequests.build({recipientId: this.user.id})};
  },
  methods: {
    submit() {
      this.contactRequest.save().then(() => {
        Flash.success("contact_request_form.email_sent", {name: this.user.name});
        EventBus.$emit('closeModal')
      });
    }
  }
};

</script>
<template>

<v-card class="contact-user-modal">
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="{ path: 'contact_request_form.modal_title', args: { name: user.name }}"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text class="contact-user-form">
    <v-textarea class="contact-request-form__message" v-model="contactRequest.message" maxlength="500" :label="$t('contact_request_form.message_placeholder')"></v-textarea>
    <validation-errors :subject="contactRequest" field="message"></validation-errors>
    <p v-t="{ path: 'contact_request_form.helptext', args: { name: user.firstName() }}"></p>
  </v-card-text>
  <v-card-actions>
    <v-spacer></v-spacer>
    <v-btn class="contact-request-form__submit" @click="submit()" v-t="'common.action.send'" color="primary"></v-btn>
  </v-card-actions>
</v-card>
</template>
