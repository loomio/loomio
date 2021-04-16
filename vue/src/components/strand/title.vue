<script lang="coffee">
import ThreadService  from '@/shared/services/thread_service'
import { map, compact, pick } from 'lodash'
import EventBus from '@/shared/services/event_bus'
import openModal      from '@/shared/helpers/open_modal'

export default
  props:
    discussion: Object

  computed:

    status: ->
      return 'pinned' if @discussion.pinned

    statusTitle: ->
      @$t("context_panel.thread_status.#{@status}")


</script>

<template lang="pug">
.thread-title
  h1.display-1.context-panel__heading#sequence-0.py-1(tabindex="-1" v-observe-visibility="{callback: titleVisible}")
    span(v-if='!discussion.translation.title') {{discussion.title}}
    span(v-if='discussion.translation.title')
      translation(:model='discussion', field='title')
    i.mdi.mdi-pin.context-panel__heading-pin(v-if="status == 'pinned'")
</template>
