<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'

import { submitForm }    from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

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
        # EventBus.emit $scope, 'processing'
        @groupIdentity.customFields.slack_channel_name = '#' + _.find($scope.channels, (c) ->
          c.id == $scope.groupIdentity.customFields.slack_channel_id
        ).name
      successCallback: -> EventBus.$emit 'nextStep'
      cleanupFn:       -> EventBus.$emit 'doneProcessing'

    @fetchChannels()

    # submitOnEnter @, anyEnter: true
    # EventBus.$emit @, 'focus'
</script>
<template lang="pug">
.install-slack-invite-form
  h2.lmo-h2(v-t="'install_slack.invite.heading'")
  p.lmo-hint-text(v-t="'install_slack.invite.helptext'")
  v-select(return-object v-model='groupIdentity.customFields.slack_channel_id', placeholder="$t('install_slack.invite.select_a_channel')" :items="channels" item-text="name")
  .poll-common-checkbox-option__text
    h3(v-t="'install_slack.invite.publish_group'")
    p.caption(v-t="'install_slack.invite.publish_group_helptext_on'", v-if='groupIdentity.makeAnnouncement')
    p.caption(v-t="'install_slack.invite.publish_group_helptext_off'", v-if='!groupIdentity.makeAnnouncement')
  v-checkbox(v-model='groupIdentity.makeAnnouncement')
  .install-slack-form__actions
    v-btn(:disabled='!groupIdentity.customFields.slack_channel_id', v-t="'install_slack.invite.set_channel'", @click='submit()')
</template>
