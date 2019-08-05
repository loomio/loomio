<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'

import { head, filter, sortBy } from 'lodash'
import { submitForm }    from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

export default
  props:
  data: ->
    group: null
    newGroup: Records.groups.build(name: Session.user().identityFor('slack').customFields.slack_team_name)
  methods:
    groups: ->
      sortBy(Session.user().adminGroups(), 'fullName')

    toggleExistingGroup: ->
      @setSubmit(if @group.id then @newGroup else head(@groups()))

    setSubmit: (group) ->
      @group = group
      @submit = submitForm @, @group,
        prepareFn: ->
          # EventBus.$emit 'processing'
          @group.identityId = Session.user().identityFor('slack').id
        flashSuccess: 'install_slack.install.slack_installed'
        skipClose: true
        successCallback: (response) ->
          g = Records.groups.find(response.groups[0].key)
          LmoUrlService.goTo LmoUrlService.group(g)
          # EventBus.emit $scope, 'nextStep', g
  created: ->
    @setSubmit(head(@groups()) or newGroup)

    submitOnEnter @, anyEnter: true
</script>
<template lang="pug">
.install-slack-install-form
  h2.lmo-h2(v-t="'install_slack.install.heading'")
  .install-slack-install-form__add-to-group(v-if='group.id')
    p.lmo-hint-text(v-t="'install_slack.install.add_to_group_helptext'")
    v-select(return-object v-model='group' @change='setSubmit(group)' :items="groups()" item-text="fulName")
    .lmo-flex.install-slack-form__actions(layout='column')
      v-btn(v-t="'install_slack.install.install_slack'", @click='submit()')
      v-button(v-t="'install_slack.install.start_new_group'", @click='toggleExistingGroup()')
  .install-slack-install-form__create-new-group(v-if='!group.id')
    p.lmo-hint-text(v-t="'install_slack.install.create_new_group_helptext'")
    .install-slack-install-form__group
      label(v-t="'install_slack.install.group_name'")
      v-text-field.lmo-primary-form-input(type='text', placeholder="$t('install_slack.install.group_name_placeholder')", v-model='group.name')
    .install-slack-form__actions
      v-btn.install-slack-install-form__submit(v-t="'install_slack.install.install_slack'", @click='submit()')
      v-btn(v-if='groups().length', v-t="'install_slack.install.use_existing_group'", @click='toggleExistingGroup()')
</template>
