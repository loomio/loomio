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
      tasksByRecordKey: {},
      loading: true
    };
  },

  mounted() {
    Records.tasks.remote.fetch('/').then(data => {
      const ids = data['tasks'].map(t => t.id);
      const tasks = Records.tasks.find(ids).filter(t => t.record() != null);
      tasks.forEach(t => {
        const recordKey = t.recordType + t.recordId;
        if ((this.records[recordKey] == null)) {
          this.records[recordKey] = t.record();
        }
      });
      this.tasksByRecordKey = groupBy(tasks, t => t.recordType + t.recordId);
    }).finally(() => {
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
    }
  }
};

</script>

<template>

<v-main>
  <v-container class="dashboard-page max-width-1024 px-0 px-sm-3">
    <h1 class="display-1 my-4" tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'tasks.your_tasks'"></h1>
    <loading v-if="loading"></loading>
    <template v-for="(tasks, recordKey) in tasksByRecordKey">
      <v-card class="mb-3">
        <v-card-title>
          <router-link :to="taskUrlFor(records[recordKey])">{{records[recordKey].discussion().title}}</router-link>
        </v-card-title>
        <v-list subheader="subheader">
          <v-list-item v-for="task in tasks" :key="task.id">
            <v-list-item-action>
              <v-btn color="accent" icon="icon" @click="toggleDone(task)">
                <common-icon v-if="task.done" name="mdi-checkbox-marked"></common-icon>
                <common-icon v-else name="mdi-checkbox-blank-outline"></common-icon>
              </v-btn>
            </v-list-item-action>
            <v-list-item-title>{{task.name}}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-card>
    </template>
    <p v-if="!loading && Object.keys(records).length == 0" v-t="'tasks.no_tasks_assigned'"></p>
    <div class="d-flex justify-center">
      <v-chip outlined="outlined" href="https://help.loomio.org/en/user_manual/threads/thread_admin/tasks.html" target="_blank">
        <common-icon class="mr-2" name="mdi-help-circle-outline"></common-icon><span v-t="'common.help'"></span><span>:</span>
        <space></space><span v-t="'tasks.tasks'"></span>
      </v-chip>
    </div>
  </v-container>
</v-main>
</template>
