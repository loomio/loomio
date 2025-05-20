<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import Flash  from '@/shared/services/flash';

export default
{
  props: {
    group: Object,
    close: Function
  },

  methods: {
    submit() {
      this.membershipRequest.save().then(() => {
        Flash.success('membership_request_form.messages.membership_requested', {group: this.group.fullName});
        this.close();
      });
    }
  },

  data() {
    return {
      membershipRequest: Records.membershipRequests.build({
        groupId: this.group.id,
        name: Session.user().name,
        email: Session.user().email,
        introduction: null
      })
    };
  },

  computed: {
    validIntro() { return (this.membershipRequest.introduction || '').length > 5 },
    isSignedIn() { return Session.isSignedIn(); }
  }
};
</script>
<template lang="pug">
v-card.membership-request-form(:title="$t('membership_request_form.heading')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    p.mb-4.text-medium-emphasis
      span(v-if="!group.requestToJoinPrompt" v-t="'group_form.default_request_to_join_prompt'")
      span(v-else="!group.requestToJoinPrompt") {{group.requestToJoinPrompt}}
    .membership-request-form__visitor(v-if='!isSignedIn')
      v-text-field.membership-request-form__name(v-model='membershipRequest.name' :required='true' :label="$t('membership_request_form.name_label')")
      v-text-field.membership-request-form__email(v-model='membershipRequest.email' :required='true' :label="$t('membership_request_form.email_label')")
      validation-errors(:subject='membershipRequest' field='email')
    .membership-request-form__reason
      v-textarea.membership-request-form__introduction(v-model='membershipRequest.introduction' required maxlength='250' :label="$t('membership_request_form.introduction_label')")
  v-card-actions
    v-spacer
    v-btn.membership-request-form__submit-btn(
      :disabled="!validIntro"
      variant="elevated"
      color="primary"
      @click='submit'
    )
      span(v-t="'membership_request_form.submit_button'")
</template>
