<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import utils          from '@/shared/record_store/utils'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import AbilityService from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import AppConfig      from '@/shared/services/app_config'
import Flash   from '@/shared/services/flash'
import { audiencesFor, audienceValuesFor } from '@/shared/helpers/announcement'
import {each , sortBy, includes, map, pull, uniq, throttle, debounce, merge} from 'lodash'
import { encodeParams } from '@/shared/helpers/encode_params'


export default
  props:
    close: Function
    model:
      type: Object
      required: true

  data: ->
    historyData: []
    historyLoading: false
    historyError: false

  created: ->
    @historyLoading = true
    Records.announcements.fetchHistoryFor(@model).then (data) =>
      @historyLoading = false
      @historyData = data || []
    , (err) =>
      @historyLoading = false
      @historyError = true

  computed:
    modelKind: -> @model.constructor.singular
    pollType: -> @model.pollType
    translatedPollType: -> @model.poll().translatedPollType() if @model.isA('poll') or @model.isA('outcome')

</script>

<template lang="pug">
v-card
  v-card-title
    h1.headline(v-t="'announcement.' + modelKind + '_notification_history'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-layout(justify-center)
    v-progress-circular(color="primary" v-if="historyLoading" indeterminate)
  v-card-text(v-if="!historyLoading")
    p(v-if="historyError && historyData.length == 0" v-t="'announcement.history_error'")
    p(v-if="!historyError && historyData.length == 0" v-t="'announcement.no_notifications_sent'")
    p(v-if="historyData.length" v-t="'announcement.notification_history_explanation'")
    div(v-for="event in historyData" :key="event.id")
      h4.mt-4.mb-2
        time-ago(:date="event.created_at")
        mid-dot
        span(v-t="{ path: 'announcement.notified_people', args: { name: event.author_name, length: event.notifications.length } }")
      ul(style="list-style-type: none; padding-left: 0")
        li(v-for="notification in event.notifications" :key="notification.id")
          span {{notification.to}}
          space
          span(v-if="notification.viewed") ✓
</template>
