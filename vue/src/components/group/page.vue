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
        @openGroupWizard(@group) if @group && @group.description.length == 0

      , (error) ->
        EventBus.$emit 'pageError', error

</script>

<template lang="pug">
loading(:until='group')
  //- group-cover-image(:group="group")
  v-container.group-page.max-width-1024
    //- group-description-card(:group='group')
    router-view
      //-   v-tabs(fixed-tabs v-model="activeTab" show-arrows)
      //-     v-tab(v-for="tab of tabs" :key="tab.id" :to="tab.route" :class="'group-page-' + tab.name + '-tab' " exact)
      //-       span(v-t="'group_page.'+tab.name")
      //-   v-divider
</template>
