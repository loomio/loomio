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
  v-card-text
    .md-toolbar-tools.lmo-flex__space-between
      h1.lmo-h1(v-t="'membership_request_form.heading'")
      dismiss-modal-button(:close="close")
  v-card-text
    .membership-request-form__visitor(v-if='!isSignedIn')
      .md-block
        label(for='membership-request-name', v-t="'membership_request_form.name_label'")
        v-text-field#membership-request-name.membership-request-form__name(v-model='membershipRequest.name', :required='true')
      .md-block
        label(for='membership-request-email', v-t="'membership_request_form.email_label'")
        v-text-field#membership-request-email.membership-request-form__email(v-model='membershipRequest.email', :required='true')
        validation-errors(:subject='membershipRequest', field='email')
    .membership-request-form__reason
      .md-block
        label(for='membership-request-introduction', v-t="'membership_request_form.introduction_label'")
        v-textarea#membership-request-introduction.lmo-textarea.membership-request-form__introduction(v-model='membershipRequest.introduction', :required='false', maxlength='250')
  v-card-actions.lmo-md-actions
    v-btn.membership-request-form__cancel-btn(@click='close()', type='button', v-t="'common.action.cancel'")
    v-btn.md-raised.md-primary.membership-request-form__submit-btn(@click='submit()', v-t="'membership_request_form.submit_button'")
</template>
