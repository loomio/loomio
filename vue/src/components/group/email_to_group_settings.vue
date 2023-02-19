<script lang="coffee">
import Session from '@/shared/services/session'
import AppConfig from '@/shared/services/app_config'
import GroupService from '@/shared/services/group_service'
import Flash from '@/shared/services/flash'
import Records from '@/shared/services/records'

export default
  props:
    group: Object

  data: ->
    key: null
    confirmReset: false
    loading: false

  created: ->
    Records.remote.get('profile/email_api_key').then (data) =>
      @key = data.email_api_key

  computed:
    address: ->
      "#{@group.fullName} <#{@group.handle}+u=#{Session.user().id}&k=#{@key}@#{AppConfig.theme['reply_hostname']}>"

  methods:
    resetKey: ->
      @loading = true
      Records.remote.post('profile/reset_email_api_key').then (data) =>
        @key = data.email_api_key
        Flash.success('email_to_group.new_address_generated')
      .finally =>
        @loading = false
        @confirmReset = false

    copyText: ->
      navigator.clipboard.writeText(@address);
      Flash.success("email_to_group.email_address_copied_to_clipboard")

    sendGroupAddress: ->
      Records.remote.post('profile/send_email_to_group_address', {group_id: @group.id}).then =>
        Flash.success('email_to_group.email_address_sent_to_you')

</script>
<template lang="pug">
v-card.email-to-group-settings
  div(v-if="!confirmReset")
    v-card-title
      h1.text-h6(v-t="'email_to_group.start_threads_via_email'")
      v-spacer
      dismiss-modal-button
    v-card-text
      p(v-t="'email_to_group.your_address_for_this_group'")
      v-text-field(
        readonly
        outlined
        v-model="address"
        append-icon="mdi-content-copy"
        @click:append="copyText"
      )
      p
        span(v-t="'email_to_group.send_email_to_start_thread'")
        space
        span(v-t="'email_to_group.subject_body_attachments'")
        space
        span(v-t="'email_to_group.address_starts_threads_as_you'")

      .d-flex.flex-wrap
        v-btn(@click="confirmReset = true" v-t="'common.reset'")
        v-spacer
        //- v-btn(@click="sendGroupAddress" v-t="'email_to_group.email_me_this_address'")
  div(v-if="confirmReset")
    v-card-title
      h1.text-h6(v-t="'email_to_group.generate_new_address_question'")
    v-card-text
      p(v-t="'email_to_group.generate_new_address_warning'")
      .d-flex
        v-btn(@click="confirmReset = false" v-t="'common.action.cancel'")
        v-spacer
        v-btn(:loading="loading" @click="resetKey" v-t="'email_to_group.generate_new_address'")

</template>
