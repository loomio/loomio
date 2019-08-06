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
  methods:
    fetchChannels: ->
      Records.identities.performCommand(Session.user().identityFor('slack').id, 'channels').then (response) =>
        @channels = response

    groups: ->
      sortBy(Session.user().adminGroups(), 'fullName')

    setSubmit: () ->
      @submit = submitForm @, @groupIdentity,
        prepareFn: =>
          console.log 'prepareFn', @channels
          @groupIdentity.customFields.slack_channel_name = '#' + _.find(@channels, (c) =>
            c.id == @groupIdentity.customFields.slack_channel_id
          ).name
        flashSuccess: 'install_slack.install.slack_installed'
        successCallback: -> EventBus.$emit 'nextStep'
        cleanupFn:       -> EventBus.$emit 'doneProcessing'

  created: ->
    @fetchChannels().then =>
      console.log 'fetchChannels .then'
      @group = head(@groups())
      @groupIdentity = Records.groupIdentities.build(
        groupId: @group.id
        identityType: 'slack'
        makeAnnouncement: true
      )
      @setSubmit()
  watch:
    group: ->
      console.log 'selected group changed'
      @groupIdentity = Records.groupIdentities.build(
        groupId: @group.id
        identityType: 'slack'
        makeAnnouncement: true
      )
      @setSubmit()
</script>
<template lang="pug">
v-card.install-slack-install-form
  v-card-title
    h2(v-t="'install_slack.install.heading'")
    dismiss-modal-button(:close="close")
  v-card-text
    .install-slack-install-form__add-to-group(v-if='group.id')
      p.lmo-hint-text(v-t="'install_slack.install.add_to_group_helptext'")
      v-select(return-object v-model='group' @change='setSubmit(group)' :items="groups()" item-text="fullName")


    .install-slack-install-form__add-to-group(v-if='groupIdentity')
      p.lmo-hint-text(v-t="'install_slack.invite.helptext'")
      v-select(return-object v-model='groupIdentity.customFields.slack_channel_id', :placeholder="$t('install_slack.invite.select_a_channel')" :items="channels" item-text="name")
      v-checkbox(v-model='groupIdentity.makeAnnouncement')
        div(slot="label")
          h3(v-t="'install_slack.invite.publish_group'")
          p.caption(v-t="'install_slack.invite.publish_group_helptext_on'", v-if='groupIdentity.makeAnnouncement')
          p.caption(v-t="'install_slack.invite.publish_group_helptext_off'", v-if='!groupIdentity.makeAnnouncement')
    //- v-card-actions.install-slack-form__actions
    //-   v-btn(:disabled='!groupIdentity.customFields.slack_channel_id', v-t="'install_slack.invite.set_channel'", @click='submit()')


  v-card-actions.install-slack-form__actions
    v-btn(v-t="'install_slack.install.install_slack'", @click='submit()')
        //- v-btn(v-t="'install_slack.install.start_new_group'", @click='toggleExistingGroup()')
    //- .install-slack-install-form__create-new-group(v-if='!group.id')
    //-   p.lmo-hint-text(v-t="'install_slack.install.create_new_group_helptext'")
    //-   .install-slack-install-form__group
    //-     label(v-t="'install_slack.install.group_name'")
    //-     v-text-field.lmo-primary-form-input(type='text', placeholder="$t('install_slack.install.group_name_placeholder')", v-model='group.name')
    //- v-btn.install-slack-install-form__submit(v-t="'install_slack.install.install_slack'", @click='submit()')
    //- v-btn(v-if='groups().length', v-t="'install_slack.install.use_existing_group'", @click='toggleExistingGroup()')
</template>
