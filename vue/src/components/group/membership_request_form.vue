<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import { submitForm } from '@/shared/helpers/form'

export default
  props:
    group: Object
    close: Function
  created: ->
    @submit = submitForm @, @membershipRequest,
      flashSuccess: 'membership_request_form.messages.membership_requested'
      flashOptions:
        group: @group.fullName
      successCallback: =>
        @close()
  data: ->
    membershipRequest: Records.membershipRequests.build
      groupId: @group.id
      name:    Session.user().name
      email:   Session.user().email
    isDisabled: false
  computed:
    isSignedIn: -> Session.isSignedIn()
</script>
<template lang="pug">
v-card.membership-request-form
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    h1.headline(v-t="'membership_request_form.heading'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    .membership-request-form__visitor(v-if='!isSignedIn')
      v-text-field.membership-request-form__name(v-model='membershipRequest.name' :required='true' :label="$t('membership_request_form.name_label')")
      v-text-field.membership-request-form__email(v-model='membershipRequest.email' :required='true' :label="$t('membership_request_form.email_label')")
      validation-errors(:subject='membershipRequest', field='email')
    .membership-request-form__reason
      v-textarea.membership-request-form__introduction(v-model='membershipRequest.introduction', :required='false', maxlength='250' :label="$t('membership_request_form.introduction_label')")
  v-card-actions
    v-btn.membership-request-form__cancel-btn(@click='close()' v-t="'common.action.cancel'")
    v-spacer
    v-btn.membership-request-form__submit-btn(color="primary" @click='submit()' v-t="'membership_request_form.submit_button'")
</template>
