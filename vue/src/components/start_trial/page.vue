<script setup>
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import { ref, useTemplateRef, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { groupCategoryItems } from '@/shared/helpers/group_categories';
import TurnstileWidget from '@/components/auth/turnstile_widget.vue';

const { t } = useI18n();
const router = useRouter();

const userName = ref(null);
const userEmail = ref(null);
const groupName = ref(null);
const groupCategory = ref(null);
const isLoading = ref(false);
const trialStarted = ref(false);
const errors = ref({});
const isSignedIn = Session.isSignedIn();
const turnstileSiteKey = AppConfig.turnstileSiteKey;
const turnstileToken = ref('');
const submitBlockedByCaptcha = computed(() => !isSignedIn && Boolean(turnstileSiteKey) && !turnstileToken.value);

const form = useTemplateRef('form');

const trialDays = AppConfig.features.app.trial_days;
const categoryItems = computed(() => groupCategoryItems(t));
const signInHref = computed(() => {
  const params = new URLSearchParams({
    user_email: userEmail.value || '',
    auth_form: 'emailCode'
  });
  return `/dashboard?${params.toString()}`;
});

const validate = (field) => {
  return [ () => errors.value[field] === undefined || errors.value[field][0] ];
};

const submit = () => {
  if (isLoading.value || submitBlockedByCaptcha.value) { return; }
  errors.value = {};
  form.value.resetValidation();
  isLoading.value = true;
  Records.remote.post('trials', {
    user_name: userName.value,
    user_email: userEmail.value,
    group_name: groupName.value,
    group_category: groupCategory.value,
    turnstile_token: turnstileToken.value,
  }).then((data) => {
    if (isSignedIn) {
      Flash.success('discussions_panel.welcome_to_your_new_group');
      return router.push(data.group_path);
    } else {
      trialStarted.value = true;
      isLoading.value = false;
    }
  }).catch((data) => {
    errors.value = data.errors || {};
    form.value.validate();
    Flash.error(data.errors ? 'common.check_for_errors_and_try_again' : 'common.please_try_again');
    isLoading.value = false;
  });
};
</script>

<template lang="pug">
v-main
  v-container.group-page.max-width-800
    v-form(ref="form" @submit.prevent="submit")
      v-card.trial-started(v-if="trialStarted" :title="t('start_trial.success')")
        v-card-text
          p.text-body-large {{ t('start_trial.account_created_for_you', { email: userEmail }) }}
          p.text-body-large {{ t('start_trial.please_sign_in_to_continue') }}
        v-card-actions
          v-spacer
          v-btn.trial-started__sign-in(color="primary" :href="signInHref" variant="elevated")
            span {{ t('auth_form.sign_in') }}
          v-spacer
      v-card.start-trial-form(v-else :title="t('start_trial.title')")
        v-card-text
          p.text-body-large.pb-6.text-medium-emphasis {{ t('start_trial.intro', { day: trialDays }) }}
          v-text-field.start-trial-form__group-name(v-model="groupName" :label="t('group_form.organization_name')" :rules="validate('group_name')")
          v-select.start-trial-form__category(
            v-model="groupCategory"
            :items="categoryItems"
            :item-props="item => ({ class: 'start-trial-form__category--' + item.value })"
            :label="t('group_survey.describe_other')"
            :rules="validate('group_category')"
          )
            template(#item="{ props, item }")
              v-list-item(v-bind="props" :lines="item.raw.subtitle ? 'two' : 'one'")
                template(#subtitle v-if="item.raw.subtitle")
                  span.text-wrap {{ item.raw.subtitle }}
          v-text-field.start-trial-form__name(v-if="!isSignedIn" v-model="userName" :label="t('start_trial.your_name')" :rules="validate('user_name')")
          v-text-field.start-trial-form__email(v-if="!isSignedIn" v-model="userEmail" :label="t('start_trial.your_email')" type="email" :rules="validate('user_email')")
          turnstile-widget(v-if="!isSignedIn" v-model="turnstileToken")
        v-card-actions
          v-spacer
          v-btn.start-trial-form__submit(variant="elevated" :loading="isLoading" color="primary" type="submit" :disabled="submitBlockedByCaptcha")
            span {{ t('templates.start_free_trial') }}
</template>
