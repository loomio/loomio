<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'
import Flash  from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'
import { head, filter, sortBy } from 'lodash'

export default
  props:
    close: Function
    group: Object

  data: ->
    groupIdentity: null
    channels: []
    channel: null

  methods:
    fetchChannels: ->
      Records.identities.performCommand(Session.user().identityFor('slack').id, 'channels').then (response) =>
        @channels = response

    submit: ->
      @groupIdentity = Records.groupIdentities.build
        groupId: @group.id
        identityType: 'slack'
        makeAnnouncement: true
        customFields:
          slack_channel_id: @channel.id
          slack_channel_name: '#' + @channel.name
      @groupIdentity.save()
      .then =>
        Flash.success 'install_slack.install.slack_installed'
        @close()
        @$router.push({ query: null })
      .catch onError(@groupIdentity)

  created: ->
    Records.users.fetchGroups().then =>
      @fetchChannels()

</script>
<template lang="pug">
.install-slack-install-form
  loading(:until="channels.length")
  v-card-text(v-if="channels.length")
    .install-slack-install-form__add-to-channel
      p.lmo-hint-text(v-t="'install_slack.invite.helptext'")
      v-select(return-object v-model='channel', :placeholder="$t('install_slack.invite.select_a_channel')" :items="channels" item-text="name")

  v-card-actions.install-slack-form__actions
    v-spacer
    v-btn(color='primary' v-t="'install_slack.install.install_slack'" @click='submit()')
</template>
