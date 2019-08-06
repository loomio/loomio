<script lang="coffee">
import Records           from '@/shared/services/records'
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Session      from '@/shared/services/session'
import EventBus     from '@/shared/services/event_bus'
import ModalService from '@/shared/services/modal_service'
import ConfirmModalMixin from '@/mixins/confirm_modal'
import InstallSlackModalMixin from '@/mixins/install_slack_modal'
import { find } from 'lodash'

export default
  mixins: [ConfirmModalMixin, InstallSlackModalMixin]
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
  created: ->
    EventBus.$emit 'currentComponent', { page: 'installSlackPage' }
    @openInstallSlackModal(null, true) if Session.user().identityFor('slack')

  methods:
    show: ->
      true
      # AbilityService.canAdministerGroup(@group) &&
      # find AppConfig.identityProviders, (provider) -> provider.name == 'slack'

    groupIdentity: ->
      @group.groupIdentityFor('slack')

    install: ->
      @openInstallSlackModal(@group, false)

    canRemoveIdentity: ->
      AbilityService.canAdministerGroup($scope.group)

    remove: ->
      @openConfirmModal
        submit:     @groupIdentity().destroy
        text:
          title:    'install_slack.card.confirm_remove_title'
          helptext: 'install_slack.card.confirm_remove_helptext'
          flash:    'install_slack.card.identity_removed'
</script>

<template lang="pug">
.install-slack-page(v-if='show()')
  h2.lmo-card-heading(v-if='groupIdentity()', v-t="'install_slack.card.installed_title'")
  h2.lmo-card-heading(v-if='!groupIdentity()', v-t="'install_slack.card.install_title'")
  .lmo-flex
    v-img.install-slack-card__logo(src='/img/slack-icon-color.svg')
    div(v-if='groupIdentity()')
      p.install-slack-card__helptext.lmo-hint-text(v-t="{ path: 'install_slack.card.installed_helptext', args: { channel: groupIdentity().slackChannelName(), team: groupIdentity().slackTeamName() } }")
      a.lmo-pointer(v-if='canRemoveIdentity()', @click='remove()', v-t="'install_slack.card.remove_identity'")
    p.install-slack-card__helptext.lmo-hint-text(v-if='!groupIdentity()', v-t="'install_slack.card.install_helptext'")
  .lmo-md-actions
    //- outlet(name='install-slack-card-footer')
    v-btn(v-t="'install_slack.card.install_slack'", @click='install()', v-if='!groupIdentity()')
</template>
