<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import EventBus           from '@/shared/services/event_bus'
import AbilityService     from '@/shared/services/ability_service'

import {groupBy} from 'lodash'

export default
  data: ->
    records: {}
    tasksByRecordKey: {}

  mounted: ->
    Records.tasks.remote.fetch('/').then (data) =>
      ids = data['tasks'].map (t) -> t.id
      tasks = Records.tasks.find(ids)
      tasks.forEach (t) =>
        recordKey = t.recordType + t.recordId
        if !@records[recordKey]?
          @records[recordKey] = t.record()
      @tasksByRecordKey = groupBy tasks, (t) -> t.recordType + t.recordId

  methods:
    toggleDone: (task) ->
      task.toggleDone()

</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'tasks.your_tasks'")

    loading(v-if="Object.keys(records).length == 0")
    template(v-for="(tasks, recordKey) in tasksByRecordKey")
      v-card.mb-3
        v-card-title
          router-link(:to="urlFor(records[recordKey])") {{records[recordKey].discussion().title}}
        v-list(subheader)
          v-list-item(v-for="task in tasks" :key="task.id")
            v-list-item-action
              v-btn(color="accent" icon @click="toggleDone(task)")
                v-icon(v-if="task.done") mdi-checkbox-marked
                v-icon(v-else) mdi-checkbox-blank-outline
            v-list-item-title {{task.name}}
</template>
