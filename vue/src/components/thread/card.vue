<script lang="coffee">
import LmoUrlService     from '@/shared/services/lmo_url_service'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import RecordLoader      from '@/shared/services/record_loader'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import PaginationService from '@/shared/services/pagination_service'
import WatchRecords from '@/mixins/watch_records'
import UrlFor from '@/mixins/url_for'

import { scrollTo }         from '@/shared/helpers/layout'
import { registerKeyEvent } from '@/shared/helpers/keyboard'
import {compact} from 'lodash'

export default
  mixins: [UrlFor]
  props:
    discussion: Object
  data: ->
    activeTab: 1
    tabs: [
      {id: 1, route: '', name: 'Activity'}
      {id: 2, route: 'polls', name: 'Polls'}
      {id: 3, route: 'members', name: 'Participants'}
    ]
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(v-if="discussion" :discussion="discussion")
  v-card
    v-tabs(fixed-tabs lazy v-model="activeTab")
      v-tab(:to="urlFor(discussion)")
        | Comments
      v-tab(:to="'/d/'+discussion.key+'/polls'")
        | Polls
      v-tab(:to="'/d/'+discussion.key+'/members'")
        | Members
    router-view
</template>
