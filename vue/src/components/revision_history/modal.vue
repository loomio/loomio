<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'

import { applyLoadingFunction } from '@/shared/helpers/apply.coffee'
import { exact } from '@/shared/helpers/format_time'

export default
  props:
    model: Object
    close: Function

  created: ->
    @getVersion(@model.versionsCount - 1)

  data: ->
    index: 1
    version: null

  methods:
    getVersion: (index) ->
      @index = index
      @version = null
      Records.versions.fetchVersion(@model, index).then (data) =>
        @version = Records.versions.find(data.versions[0].id)

    getNext: ->
      if !@isNewest
        @getVersion(@index + 1)

    getPrevious: ->
      if !@isOldest
        @getVersion(@index - 1)

  computed:
    versionDate: ->
      exact @version.createdAt

    isOldest: ->
      @index == 0

    isNewest: ->
      @index == @model.versionsCount - 1

</script>

<template lang="pug">
v-card.revision-history-modal
  v-card-title
    h1.headline(v-t="'revision_history_modal.' + model.constructor.singular + '_header'")
    v-spacer
    dismiss-modal-button(:close="close")
  .revision-history-modal__body.pa-4
    v-layout(align-center justify-space-between)
      v-btn.revision-history-nav--previous(icon :disabled='isOldest' @click='getPrevious()')
        v-icon mdi-arrow-left

      span(v-if="version" v-t="{path: 'revision_history_modal.edit_by', args: {name: version.authorName(), date: versionDate}}")

      v-btn.revision-history-nav--next(icon :disabled='isNewest' @click='getNext()')
        v-icon mdi-arrow-right
    v-divider.mb-3
    revision-history-content(v-if='version' :model='model' :version='version')
</template>
