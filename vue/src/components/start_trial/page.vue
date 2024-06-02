<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Records  from '@/shared/services/records';
import Session  from '@/shared/services/session';
import Flash   from '@/shared/services/flash';
import I18n from '@/i18n';
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service';
// import EventBus   from '@/shared/services/event_bus';

const emailRegex = /[^:,;'"`<>]+?@[^:,;'"`<>]+\.[^:,;'"`<>]+/
export default
{
  data() {

    return {
      userName: Session.user().name || '',
      userEmail: Session.user().email || '',
      group: Records.groups.build({description: I18n.t('group_form.new_description_html')}),
      howDidYouHearAboutLoomio: '',
      validate: false,
      newsletter: false,
      acceptTerms: false,
      trialStarted: false,
      groupCategory: '',
      nameRules: [value => { if (!this.validate) {return true}; if (value.length > 2) return true; return this.$t('start_trial.please_complete_this_field');}],
      emailRules: [value => { if (!this.validate) {return true}; if (emailRegex.test(value)) return true; return this.$t('start_trial.please_enter_a_valid_email_address');}],
      checkRules: [value => { if (!this.validate) {return true}; if (value){ return true } ; return this.$t('start_trial.please_accept_the_terms');}],
      loading: false,
    };
  },

  methods: {
    submit() {
      this.validate = true;
      if (this.$refs.form.validate()){
        RescueUnsavedEditsService.models = [];
        this.group.beforeSaves.forEach(f => f());
        this.loading = true
        Records.remote.post('trials', {
          user_name: this.userName,
          user_email: this.userEmail,
          newsletter: this.newsletter,
          group: this.group.serialize().group,
          how_did_you_hear_about_loomio: this.howDidYouHearAboutLoomio,
          group_category: this.groupCategory,
        }).then((data) => {
          this.trialStarted = true
          if (this.isSignedIn) {
            Flash.success('discussions_panel.welcome_to_your_new_group');
            this.$router.push(data.group_path)
          }
        }).catch(error => {
          Flash.custom(error.error, 'error', 5000);
        }).finally(() => {
          this.loading = false
        });
      }
    },
  },
  computed: {
    isSignedIn() {
      return Session.isSignedIn();
    },
    categoryItems() {
      // ['board', 'community', 'coop', 'membership', 'nonprofit', 'party', 'professional', 'self_managing', 'union', 'other'].map (category) ->
      return ['board', 'membership', 'self_managing', 'other'].map(category => ({
        text: I18n.t('group_survey.categories.'+category),
        value: category
      }));
    }, 

    canSubmit() { return this.userName && this.userEmail && this.groupName && this.groupIntention && this.acceptTerms },
    trialDays() { return AppConfig.features.app.trial_days; },
    termsUrl() { return AppConfig.theme.terms_url; },
    privacyUrl() { return AppConfig.theme.privacy_url; },
  }
};
</script>

<template lang="pug">
v-main
  v-container.group-page.max-width-800
    v-card.trial-started(v-if="trialStarted")
      v-card-text
        p.text-h4(v-t="'start_trial.success'")
        p(v-t="'start_trial.taken_first_step'")
        p(v-t="{path: 'start_trial.account_created_for_you', args: {email: userEmail}}")
        p(v-t="'start_trial.please_sign_in_to_continue'")
      v-card-actions
        v-spacer
        v-btn(color="primary" :href="'/dashboard?user_email='+userEmail" v-t="'auth_form.sign_in'")
        v-spacer
    v-card.start-trial-form(v-else)
      v-form(ref="form" @submit.prevent="submit")
        v-card-title
          h1.text-h5(v-t="'start_trial.title'")

        v-card-text
          p(v-t="{path: 'start_trial.intro', args: {day: trialDays}}")
          p(v-t="'start_trial.lets_get_started'")
          v-text-field(v-if="!isSignedIn" v-model='userName' :label="$t('start_trial.your_name')" :rules="nameRules" required)
          v-text-field(v-if="!isSignedIn" v-model='userEmail' :label="$t('start_trial.your_email')" type="email" :rules="emailRules" required)
          v-text-field(v-model='group.name' :label="$t('group_form.organization_name')" :rules="nameRules" required)
          v-select(v-model="groupCategory" :items="categoryItems" :label="$t('group_survey.describe_other')" :rules="nameRules" required)
          lmo-textarea.group-form__group-description(:model='group' field="description", :placeholder="$t('group_form.description_placeholder')", :label="$t('group_form.description')")
          v-textarea(v-model='howDidYouHearAboutLoomio' :label="$t('start_trial.how_did_you_hear_about_loomio')" :rules="nameRules")
          v-checkbox(v-model='newsletter' :label="$t('start_trial.subscribe_to_newsletter')" :hint="$t('start_trial.newsletter_description')" persistent-hint)
          v-checkbox.auth-signup-form__legal-accepted(v-model='acceptTerms' required :rules="checkRules")
            template(v-slot:label)
              i18n(path="auth_form.i_accept_all" tag="span")
                template(v-slot:termsLink)
                  a(:href='termsUrl' target='_blank' @click.stop v-t="'powered_by.terms_of_service'")
                template(v-slot:privacyLink)
                  a(:href='privacyUrl' target='_blank' @click.stop v-t="'powered_by.privacy_policy'")

        v-card-actions
          v-spacer
          v-btn(:loading="loading" color="primary" type="submit" v-t="'templates.start_free_trial'")
</template>
