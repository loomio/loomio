<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import {applyLoadingFunction } from '@/shared/helpers/apply'

export default
  props:
    model: Object

  data: ->
    currentIndex: null
    latestIndex: null

  created: ->
    @currentIndex = @latestIndex = @model.versionsCount - 1
    @getVersion()

  methods:
    getVersion: ->
      EventBus.$emit 'versionFetching'
      Records.versions.fetchVersion(@model, @currentIndex).then (data) =>
        @version = Records.versions.find(data.versions[0].id)
        @version.index = @currentIndex
        EventBus.$emit 'versionFetched', @version
        Records.groups.findOrFetchById(@version.changes.group_id[1]) if @version.changes.group_id

    setNextRevision: ->
      if !@isNewest
        @currentIndex += 1;
        @getVersion()

    setPreviousRevision: ->
      if !@isOldest
        @currentIndex -= 1;
        @getVersion()

    setOldestRevision: ->
      @currentIndex = 0
      @getVersion()

    setLatestRevision: ->
      @currentIndex = @latestIndex
      @getVersion()

  computed:
    isOldest: ->
      @currentIndex == 0

    isNewest: ->
      @currentIndex == @latestIndex


</script>
<template lang="pug">
.revision-history-nav.lmo-flex.lmo-flex--row.lmo-grey-on-white.lmo-flex__center.lmo-flex__space-between
  v-btn.md-button--tiny.revision-history-nav--oldest(:disabled='isOldest', @click='setOldestRevision()')
    v-icon mdi-arrow-collapse-left
  v-btn.md-button--tiny.revision-history-nav--previous(:disabled='isOldest', @click='setPreviousRevision()')
    v-icon mdi-arrow-left
  span.lmo-flex__grow.align-center(v-if='!isOldest && !isNewest', replace='true')
    span {{currentIndex + 1}}
    span /
    span {{model.versionsCount}}
  span.lmo-flex__grow.align-center(v-if='isOldest', v-t="'revision_history_modal.original_text'")
  span.lmo-flex__grow.align-center(v-if='isNewest', v-t="'revision_history_modal.current_revision'")
  v-btn.revision-history-nav--next(:disabled='isNewest', @click='setNextRevision()')
    v-icon mdi-arrow-right
  v-btn.revision-history-nav--latest(:disabled='isNewest', @click='setLatestRevision()')
    v-icon mdi-arrow-collapse-right
</template>
