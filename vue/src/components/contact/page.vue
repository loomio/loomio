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

<template lang="pug">
v-main
  v-container.contact-page
    v-card.contact-form(v-show='!submitted').max-width-800.px-0.px-sm-3
      submit-overlay(:value='message.processing')
      v-card-title.mx-0.px-0
        p.text-heading.mx-0(v-t="'contact_message_form.title'")

      p(v-t="'contact_message_form.respond_asap'")
      p(v-t="'contact_message_form.happy_to_help_with'")

      div(v-if='!isLoggedIn')
        v-text-field(:label="$t('contact_message_form.name_label')" :placeholder="$t('contact_message_form.name_placeholder')" v-model='message.name')
        validation-errors(:subject='message', field='name')
      div(v-if='!isLoggedIn')
        v-text-field(:label="$t('contact_message_form.email_label')" :placeholder="$t('contact_message_form.email_placeholder')", v-model='message.email')
        validation-errors(:subject='message', field='email')

      v-text-field(:label="$t('contact_message_form.subject_label')" :placeholder="$t('contact_message_form.subject_placeholder')", v-model='message.subject')
      validation-errors(:subject='message', field='subject')

      v-textarea(:label="$t('contact_message_form.message_label')" v-model='message.message', :placeholder="$t('contact_message_form.message_placeholder')")
      v-alert(type="info" v-if="needMessage")
        span(v-t="'contact_message_form.need_message'")
      validation-errors(:subject='message', field='message')

      p.text--secondary(v-html="$t('contact_message_form.contact_us_email', { email: contactEmail })")
      v-card-actions
        v-spacer
        v-btn(color="primary" @click='submit' v-t="'contact_message_form.send_message'")

    v-card.contact-form__success(v-show='submitted')
      v-card-title
        h1.text-h5(tabindex="-1" v-t="$t('contact_message_form.success_via_email', { name: message.name })")
</template>
