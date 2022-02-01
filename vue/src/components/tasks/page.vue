<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import Flash              from '@/shared/services/flash'
import EventBus           from '@/shared/services/event_bus'
import AbilityService     from '@/shared/services/ability_service'

import {groupBy} from 'lodash'

export default
  data: ->
    records: {}
    tasksByRecordKey: {}
    loading: true

  mounted: ->
    Records.tasks.remote.fetch('/').then (data) =>
      ids = data['tasks'].map (t) -> t.id
      tasks = Records.tasks.find(ids)
      tasks.forEach (t) =>
        recordKey = t.recordType + t.recordId
        if !@records[recordKey]?
          @records[recordKey] = t.record()
      @tasksByRecordKey = groupBy tasks, (t) -> t.recordType + t.recordId
    .finally =>
      @loading = false

  methods:
    taskUrlFor: (record) ->
      if record.isA('discussion')
        @urlFor(record)+'/0'
      else
        @urlFor(record)

    toggleDone: (task) ->
      task.toggleDone().then ->
        if task.done
          Flash.success 'tasks.task_updated_done'
        else
          Flash.success 'tasks.task_updated_not_done'

</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'tasks.your_tasks'")
    loading(v-if="loading")
    template(v-for="(tasks, recordKey) in tasksByRecordKey")
      v-card.mb-3
        v-card-title
          router-link(:to="taskUrlFor(records[recordKey])") {{records[recordKey].discussion().title}}
        v-list(subheader)
          v-list-item(v-for="task in tasks" :key="task.id")
            v-list-item-action
              v-btn(color="accent" icon @click="toggleDone(task)")
                v-icon(v-if="task.done") mdi-checkbox-marked
                v-icon(v-else) mdi-checkbox-blank-outline
            v-list-item-title {{task.name}}
    p(v-if="!loading && Object.keys(records).length == 0" v-t="'tasks.no_tasks_assigned'")
    .d-flex.justify-center
      v-chip(outlined href="https://help.loomio.org/en/user_manual/threads/thread_admin/tasks.html" target="_blank")
        v-icon.mr-2 mdi-help-circle-outline
        span(v-t="'common.help'")
        span :
        space
        span(v-t="'tasks.tasks'")
</template>
