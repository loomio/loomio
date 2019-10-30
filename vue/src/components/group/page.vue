<script lang="coffee">

import AppConfig         from '@/shared/services/app_config'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import LmoUrlService     from '@/shared/services/lmo_url_service'
import InstallSlackModalMixin from '@/mixins/install_slack_modal'
import GroupModalMixin from '@/mixins/group_modal'
import { subscribeTo }   from '@/shared/helpers/cable'
import {compact, head, includes, filter} from 'lodash'

export default
  mixins: [InstallSlackModalMixin, GroupModalMixin]
  data: ->
    group: null

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()
    setTimeout => @openInstallSlackModal() if @$route.query.install_slack

  watch:
    '$route.params.key': 'init'

  methods:
    init: ->
      Records.groups.findOrFetch(@$route.params.key).then (group) =>
        @group = group

        subscribeTo(@group)
        Records.drafts.fetchFor(@group) if AbilityService.canCreateContentFor(@group)

      , (error) ->
        EventBus.$emit 'pageError', error

</script>

<template lang="pug">
div
  v-content
    loading(:until='group')
      v-container.group-page.max-width-1024
        router-view
  router-view(name="nav")
</template>

<style lang="css">
.group-page-tabs .v-tab:not(.v-tab--active) {
    color: hsla(0,0%,100%,.85) !important;
}
</style>
