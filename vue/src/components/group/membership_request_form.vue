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
    isSignedIn() { return Session.isSignedIn(); }
  }
};
</script>
<template lang="pug">
v-card.membership-request-form
  submit-overlay(:value='membershipRequest.processing')
  v-card-title
    h1.text-h5(tabindex="-1" v-t="'membership_request_form.heading'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    p(v-if="!group.requestToJoinPrompt" v-t="'group_form.default_request_to_join_prompt'")
    p(v-else="!group.requestToJoinPrompt") {{group.requestToJoinPrompt}}
    .membership-request-form__visitor(v-if='!isSignedIn')
      v-text-field.membership-request-form__name(v-model='membershipRequest.name' :required='true' :label="$t('membership_request_form.name_label')")
      v-text-field.membership-request-form__email(v-model='membershipRequest.email' :required='true' :label="$t('membership_request_form.email_label')")
      validation-errors(:subject='membershipRequest' field='email')
    .membership-request-form__reason
      v-textarea.membership-request-form__introduction(v-model='membershipRequest.introduction' :required='false' maxlength='250' :label="$t('membership_request_form.introduction_label')")
  v-card-actions
    v-btn.membership-request-form__cancel-btn(@click='close()' v-t="'common.action.cancel'")
    v-spacer
    v-btn.membership-request-form__submit-btn(color="primary" @click='submit()' v-t="'membership_request_form.submit_button'")
</template>
