<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import AppConfig      from '@/shared/services/app_config';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';

export default {
  data() {
    return {
      submitted: false,
      message: Records.contactMessages.build(),
      isDisabled: false,
      helpLink: "https://help.loomio.com",
      contactEmail: AppConfig.contactEmail,
      needMessage: false
    };
  },

  mounted() {
    EventBus.$emit('currentComponent', {
      titleKey: 'contact_message_form.alt_title',
      page: 'inboxPage'
    });
  },

  created() {
    if (this.isLoggedIn) {
      this.message.name = Session.user().name;
      this.message.email = Session.user().email;
      this.message.userId = Session.user().id;
    }
  },

  methods: {
    submit() {
      if (this.message.message) {
        return this.message.save()
        .then(() => {
          this.submitted = true;
        });
      } else {
        this.needMessage = true;
      }
    }
  },

  computed: {
    isLoggedIn() {
      return Session.isSignedIn();
    }
  }
};
</script>

<template>

<v-main>
  <v-container class="contact-page">
    <v-card class="contact-form max-width-800 px-0 px-sm-3" v-show="!submitted">
      <submit-overlay :value="message.processing"></submit-overlay>
      <v-card-title class="mx-0 px-0">
        <p class="text-heading mx-0" v-t="'contact_message_form.title'"></p>
      </v-card-title>
      <p v-t="'contact_message_form.respond_asap'"></p>
      <p v-t="'contact_message_form.happy_to_help_with'"></p>
      <div v-if="!isLoggedIn">
        <v-text-field :label="$t('contact_message_form.name_label')" :placeholder="$t('contact_message_form.name_placeholder')" v-model="message.name"></v-text-field>
        <validation-errors :subject="message" field="name"></validation-errors>
      </div>
      <div v-if="!isLoggedIn">
        <v-text-field :label="$t('contact_message_form.email_label')" :placeholder="$t('contact_message_form.email_placeholder')" v-model="message.email"></v-text-field>
        <validation-errors :subject="message" field="email"></validation-errors>
      </div>
      <v-text-field :label="$t('contact_message_form.subject_label')" :placeholder="$t('contact_message_form.subject_placeholder')" v-model="message.subject"></v-text-field>
      <validation-errors :subject="message" field="subject"></validation-errors>
      <v-textarea :label="$t('contact_message_form.message_label')" v-model="message.message" :placeholder="$t('contact_message_form.message_placeholder')"></v-textarea>
      <v-alert type="info" v-if="needMessage"><span v-t="'contact_message_form.need_message'"></span></v-alert>
      <validation-errors :subject="message" field="message"></validation-errors>
      <p class="text--secondary" v-html="$t('contact_message_form.contact_us_email', { email: contactEmail })"></p>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="primary" @click="submit" v-t="'contact_message_form.send_message'"></v-btn>
      </v-card-actions>
    </v-card>
    <v-card class="contact-form__success" v-show="submitted">
      <v-card-title>
        <h1 class="headline" tabindex="-1" v-t="$t('contact_message_form.success_via_email', { name: message.name })"></h1>
      </v-card-title>
    </v-card>
  </v-container>
</v-main>
</template>
