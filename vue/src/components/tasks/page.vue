<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import EventBus           from '@/shared/services/event_bus'
import AbilityService     from '@/shared/services/ability_service'

export default
  data: ->
    tasks: [{id: 1, name: 'do the dishes'}]

</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'tasks.tasks'")
    v-card.mb-3
      v-list
        v-list-item(v-for="task in tasks" :key="task.id")
          v-list-item-title {{task.name}}
</template>
