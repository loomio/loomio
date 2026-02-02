<script setup>
import AppConfig      from '@/shared/services/app_config';
import Records  from '@/shared/services/records';
import Session  from '@/shared/services/session';
import Flash   from '@/shared/services/flash';
import { I18n } from '@/i18n';
import EventBus   from '@/shared/services/event_bus';
import { ref, useTemplateRef } from 'vue';
import { useRouter } from 'vue-router';
const router = useRouter();

const userName = ref(null);
const userEmail = ref(null);
const group = Records.groups.build({ description: I18n.global.t('group_form.new_description_html') });
const groupName = ref(null);
const groupCategory = ref(null);
const howDidYouHearAboutLoomio = ref(null);
const emailNewsletter = ref(false);
const legalAccepted = ref(false);
const loading = ref(false);
const trialStarted = ref(false);
const errors = ref({});

const form = useTemplateRef('form')

const isSignedIn = Session.isSignedIn();
const categoryItems = ['board', 'membership', 'self_managing', 'other'].map(category => ({
  title: I18n.global.t('group_survey.categories.'+category),
  value: category
}));

const trialDays = AppConfig.features.app.trial_days;
const termsUrl = AppConfig.theme.terms_url;
const privacyUrl = AppConfig.theme.privacy_url;

const validate = (field) => {
  return [ () => errors.value[field] === undefined || errors.value[field][0] ]
}


const submit = () => {
  errors.value = {};
  form.value.resetValidation();
  group.beforeSaves.forEach(f => f());
  EventBus.$emit('resetDraft', 'group', null, 'description', I18n.global.t('group_form.new_description_html'));
  loading.value = true
  Records.remote.post('trials', {
    user_name: userName.value,
    user_email: userEmail.value,
    user_email_newsletter: emailNewsletter.value,
    user_legal_accepted: legalAccepted.value,
    group_name: groupName.value,
    group_description: group.description,
    group_category: groupCategory.value,
    group_how_did_you_hear_about_loomio: howDidYouHearAboutLoomio.value,
  }).then((data) => {
    trialStarted.value= true
    if (isSignedIn) {
      Flash.success('discussions_panel.welcome_to_your_new_group');
      router.push(data.group_path)
    }
  }).catch((data) => {
    errors.value = data.errors
    form.value.validate();
    Flash.error('common.check_for_errors_and_try_again');
  }).finally(() => {
    loading.value = false
  });
}
</script>

<template lang="pug">
v-main
  v-container.group-page.max-width-800
    v-form(ref="form" @submit.prevent="submit")
      v-card.trial-started(v-if="trialStarted" :title="$t('start_trial.success')")
        v-card-text
          p.text-body-large(v-t="{path: 'start_trial.account_created_for_you', args: {email: userEmail}}")
          p.text-body-large(v-t="'start_trial.please_sign_in_to_continue'")
        v-card-actions
          v-spacer
          v-btn(color="primary" :href="'/dashboard?user_email='+userEmail" variant="elevated")
            span(v-t="'auth_form.sign_in'")
          v-spacer
      v-card.start-trial-form(v-else :title="$t('start_trial.title')")
        v-card-text
          p.text-body-large.pb-6.text-medium-emphasis(v-t="{path: 'start_trial.intro', args: {day: trialDays}}")
          v-text-field(v-if="!isSignedIn" v-model='userName' :label="$t('start_trial.your_name')" :rules="validate('user_name')")
          v-text-field(v-if="!isSignedIn" v-model='userEmail' :label="$t('start_trial.your_email')" type="email" :rules="validate('user_email')")
          v-text-field(v-model='groupName' :label="$t('group_form.organization_name')" :rules="validate('group_name')")
          v-select(v-model="groupCategory" :items="categoryItems" :label="$t('group_survey.describe_other')" :rules="validate('group_category')")
          lmo-textarea.group-form__group-description(:model='group' field="description" :placeholder="$t('group_form.description_placeholder')" :label="$t('group_form.description')")
          template(v-if="!isSignedIn")
            v-textarea(v-model='howDidYouHearAboutLoomio' :label="$t('start_trial.how_did_you_hear_about_loomio')")
            //v-divider.pb-4
            //.text-body-large.text-medium-emphasis(v-t="'start_trial.newsletter_intro'")
            //v-checkbox(v-model='emailNewsletter' :label="$t('start_trial.subscribe_to_newsletter')")
            //v-checkbox.auth-signup-form__legal-accepted(v-model='legalAccepted' :rules="validate('user_legal_accepted')")
            //  template(v-slot:label)
            //    i18n-t(keypath="auth_form.i_accept_all" tag="span")
            //      template(v-slot:termsLink)
            //        a(:href='termsUrl' target='_blank' @click.stop v-t="'powered_by.terms_of_service'")
            //      template(v-slot:privacyLink)
            //        a(:href='privacyUrl' target='_blank' @click.stop v-t="'powered_by.privacy_policy'")
        v-card-actions
          v-spacer
          v-btn(variant="elevated" :loading="loading" color="primary" type="submit")
            span(v-t="'templates.start_free_trial'")
</template>
