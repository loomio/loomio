<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'

import { head, filter, sortBy } from 'lodash'
import { submitForm }    from '@/shared/helpers/form'

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

    setSubmit: () ->
      @groupIdentity = Records.groupIdentities.build(
        groupId: @group.id
        identityType: 'slack'
        makeAnnouncement: true
      )
      @submit = submitForm @, @groupIdentity,
        prepareFn: =>
          @groupIdentity.customFields.slack_channel_id = @channel.id
          @groupIdentity.customFields.slack_channel_name = '#' + @channel.name
        flashSuccess: 'install_slack.install.slack_installed'
        successCallback: =>
          EventBus.$emit 'closeModal'
          @$router.replace({ query: {} })

  created: ->
    @group = head(@groups())
    @fetchChannels().then =>
      @setSubmit()

</script>
<template lang="pug">
.install-slack-install-form
  //- v-card-title
  //-   h2.headline(v-t="'install_slack.install.heading'")
  //-   spacer
  //-   dismiss-modal-button(:close="close")
  v-card-text
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
