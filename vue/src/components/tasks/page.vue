<script lang="js">
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import Flash              from '@/shared/services/flash';
import EventBus           from '@/shared/services/event_bus';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';
import { taskRecordTitle } from '@/shared/helpers/task_record_title.mjs';
import { manualUrl } from '@/shared/helpers/manual_url';

import {groupBy} from 'lodash-es';

export default {
  mixins: [UrlFor, FormatDate],
  props: {
    embedded: { type: Boolean, default: false }
  },
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
    manualUrl,
    taskUrlFor(record) {
      if (record.isA('discussion')) {
        return this.urlFor(record)+'/0';
      } else {
        return this.urlFor(record);
      }
    },

    taskRecordTitle,

    toggleDone(task) {
      return task.toggleDone().then(function() {
        if (task.doneAt) {
          Flash.success('tasks.task_updated_done');
        } else {
          Flash.success('tasks.task_updated_not_done');
        }
      });
    }
  }
};

</script>

<template lang="pug">
component(:is="embedded ? 'div' : 'v-main'")
  component(:is="embedded ? 'div' : 'v-container'" :class="embedded ? 'tasks-page pt-2' : 'dashboard-page max-width-1024 px-2 px-sm-4'")
    template(v-if="!embedded")
      h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'dashboard_page.dashboard'")
      dashboard-cards
    loading(v-if="loading")
    template(v-for="(tasks, recordKey) in tasksByRecordKey")
      v-card.mb-3
        v-card-title
          router-link(:to="taskUrlFor(records[recordKey])") {{taskRecordTitle(records[recordKey])}}
        v-list(subheader)
          v-list-item(v-for="task in tasks" :key="task.id" :title="task.name")
            template(v-slot:prepend)
              v-btn(color="accent" icon variant="flat" @click="toggleDone(task)" :loading="task.processing")
                common-icon(v-if="task.doneAt" name="mdi-checkbox-marked")
                common-icon(v-else name="mdi-checkbox-blank-outline")
    p(v-if="!loading && Object.keys(records).length == 0" v-t="'tasks.no_tasks_assigned'")
    .d-flex.justify-center
      v-chip(outlined :href="manualUrl('user_manual/discussions/tasks', $i18n.locale)" target="_blank")
        common-icon.mr-2(name="mdi-help-circle-outline")
        span(v-t="'common.user_guide'")
        span :
        space
        span(v-t="'tasks.tasks'")
</template>
