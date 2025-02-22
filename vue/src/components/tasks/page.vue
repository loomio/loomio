<script lang="js">
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import Flash              from '@/shared/services/flash';
import EventBus           from '@/shared/services/event_bus';
import AbilityService     from '@/shared/services/ability_service';

import {groupBy} from 'lodash-es';

export default {
  data() {
    return {
      records: {},
      tasks: [],
      loading: true,
      filterTabs: [
        {name: 'open', filter: task => !task.done && !task.hidden},
        {name: 'closed', filter: task => task.done && !task.hidden},
        {name: 'hidden', filter: task => task.hidden}
      ],
      activeFilter: 0,
    };
  },

  mounted() {
    Records.tasks.collection.data = [];
    Records.tasks.remote.fetch('/').then(data => {

      this.tasks = Records.tasks.all().filter(t => t.record() != null);

      this.tasks.forEach(t => {
        const recordKey = t.recordType + t.recordId;
        if ((this.records[recordKey] == null)) {
          this.records[recordKey] = t.record();
        }
      });

    }).finally(()=> {
      this.loading = false;
    });
  },

  methods: {
    taskUrlFor(record) {
      if (record.isA('discussion')) {
        return this.urlFor(record)+'/0';
      } else {
        return this.urlFor(record);
      }
    },

    toggleDone(task) {
      return task.toggleDone().then(function() {
        if (task.done) {
          Flash.success('tasks.task_updated_done');
        } else {
          Flash.success('tasks.task_updated_not_done');
        }
      });
    },

    toggleHidden(task) {
      return task.toggleHidden().then(function() {
        if (task.hidden) {
          Flash.success('tasks.task_updated_hidden');
        } else {
          Flash.success('tasks.task_updated_not_hidden');
        }
      });
    },

    setFilter(tabId) { this.activeFilter = tabId; },

  },

  computed: {
    filteredTasks() {
      return this.tasks.filter(this.filterTabs[this.activeFilter].filter);
    }
  }


};

</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024.px-0.px-sm-3
    h1.text-h4.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'tasks.your_tasks'")
    
    v-divider.mt-4
    v-tabs(
      background-color="transparent"
      center-active
      grow
    )
      v-tab(
        v-for="(filter, idx) of filterTabs" @click="setFilter(idx)"
      )
        span(v-t="'tasks.tasks_filters.'+filter.name")


    loading(v-if="loading")
    template()
      v-list()
        v-list-item(v-for="task in filteredTasks" :key="task.id")
          v-list-item-action
            v-btn(color="accent" icon @click="toggleDone(task)")
              common-icon(v-if="task.done" name="mdi-checkbox-marked")
              common-icon(v-else name="mdi-checkbox-blank-outline")
          v-list-item-title {{task.name}}
          v-list-item-action
            v-btn(icon @click='toggleHidden(task)')
              common-icon(v-if="task.hidden === false" name="mdi-eye-off")
              common-icon(v-else name="mdi-eye")
          v-list-item-action
            v-btn(icon :to="taskUrlFor(task.record())")
                common-icon(name="mdi-arrow-right")


    p(v-if="!loading && filteredTasks.length == 0" v-t="'tasks.no_tasks_assigned'")
    .d-flex.justify-center
      v-chip(outlined href="https://help.loomio.org/en/user_manual/threads/thread_admin/tasks.html" target="_blank")
        common-icon.mr-2(name="mdi-help-circle-outline")
        span(v-t="'common.help'")
        span :
        space
        span(v-t="'tasks.tasks'")
</template>
