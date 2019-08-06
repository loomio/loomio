<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'

import { submitForm }    from '@/shared/helpers/form'

export default
  props:
    group: Object
  data: ->
    groupIdentity: Records.groupIdentities.build(
      groupId: @group.id
      identityType: 'slack'
      makeAnnouncement: true
    )
    channels: []
  methods:
    fetchChannels: ->
      Records.identities.performCommand(Session.user().identityFor('slack').id, 'channels').then (response) ->
        @channels = response
      , (response) ->
        @error = response.data.error
  created: ->
    @submit = submitForm @, @groupIdentity,
      prepareFn: ->
        @groupIdentity.customFields.slack_channel_name = '#' + _.find($scope.channels, (c) ->
          c.id == $scope.groupIdentity.customFields.slack_channel_id
        ).name
      successCallback: -> EventBus.$emit 'nextStep'
      cleanupFn:       -> EventBus.$emit 'doneProcessing'

    @fetchChannels()

</script>
<template lang="pug">
v-card.install-slack-invite-form
  v-card-title
    h2.lmo-h2(v-t="'install_slack.invite.heading'")
  v-card-text
    p.lmo-hint-text(v-t="'install_slack.invite.helptext'")
    v-select(return-object v-model='groupIdentity.customFields.slack_channel_id', placeholder="$t('install_slack.invite.select_a_channel')" :items="channels" item-text="name")
    .poll-common-checkbox-option__text
      h3(v-t="'install_slack.invite.publish_group'")
      p.caption(v-t="'install_slack.invite.publish_group_helptext_on'", v-if='groupIdentity.makeAnnouncement')
      p.caption(v-t="'install_slack.invite.publish_group_helptext_off'", v-if='!groupIdentity.makeAnnouncement')
    v-checkbox(v-model='groupIdentity.makeAnnouncement')
  v-card-actions.install-slack-form__actions
    v-btn(:disabled='!groupIdentity.customFields.slack_channel_id', v-t="'install_slack.invite.set_channel'", @click='submit()')
</template>
