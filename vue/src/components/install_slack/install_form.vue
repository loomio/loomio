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
  data: ->
    group: null
    newGroup: Records.groups.build(name: Session.user().identityFor('slack').customFields.slack_team_name)
    groupIdentity: null
    channels: []
    channel: null
  methods:
    fetchChannels: ->
      Records.identities.performCommand(Session.user().identityFor('slack').id, 'channels').then (response) =>
        @channels = response

    groups: ->
      sortBy(Session.user().adminGroups(), 'fullName')

    submit: ->
      @groupIdentity.customFields.slack_channel_id = @channel.id
      @groupIdentity.customFields.slack_channel_name = '#' + @channel.name
      @groupIdentity.save()
      .then =>
        Flash.success 'install_slack.install.slack_installed'
        @close()
        @$router.replace({ query: {} })
      .catch onError(@groupIdentity)

  created: ->
    Records.users.fetchGroups().then =>
      @group = head(@groups())

      @fetchChannels().then =>
        @groupIdentity = Records.groupIdentities.build(
          groupId: @group.id
          identityType: 'slack'
          makeAnnouncement: true
        )

</script>
<template lang="pug">
.install-slack-install-form
  loading(v-if="!group")
  v-card-text(v-if="group")
    .install-slack-install-form__add-to-group(v-if='group.id')
      p.lmo-hint-text(v-t="'install_slack.install.add_to_group_helptext'")
      v-select(return-object v-model='group' @change='setSubmit(group)' :items="groups()" item-text="fullName")

    .install-slack-install-form__add-to-group(v-if='groupIdentity')
      p.lmo-hint-text(v-t="'install_slack.invite.helptext'")
      v-select(return-object v-model='channel', :placeholder="$t('install_slack.invite.select_a_channel')" :items="channels" item-text="name")
      v-checkbox(v-model='groupIdentity.makeAnnouncement')
        div(slot="label")
          strong(v-t="'install_slack.invite.publish_group'")
          p.caption(v-t="'install_slack.invite.publish_group_helptext_on'", v-if='groupIdentity.makeAnnouncement')
          p.caption(v-t="'install_slack.invite.publish_group_helptext_off'", v-if='!groupIdentity.makeAnnouncement')

  v-card-actions.install-slack-form__actions
    v-spacer
    v-btn(color='primary' v-t="'install_slack.install.install_slack'", @click='submit()')
</template>
