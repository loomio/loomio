<script lang="js">
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import Flash              from '@/shared/services/flash';
import EventBus           from '@/shared/services/event_bus';
import AbilityService     from '@/shared/services/ability_service';
import confirm_modal from "@/components/common/confirm_modal.vue";

import {filter, groupBy, sortBy, uniq} from 'lodash-es';

export default {
  data() {
    return {
      records: {},
      tasks: [],
      loading: true,
      filterTabs: [
        {name: 'todo', filter: task => !task.done && !task.hidden},
        {name: 'done', filter: task => task.done && !task.hidden},
        {name: 'hidden', filter: task => task.hidden}
      ],
      activeFilter: 0,
      dialog: false,
    };
  },

  mounted() {
    this.refresh();
  },

  methods: {
    refresh() {
      this.loading = true

      Records.tasks.remote.fetch({params: this.$route.query, path: '/'}).then(data => {
        const fetchedIds = data.tasks.map(t => t.id);
        const taskModelsForPath = Records.tasks.collection.chain().find({id: {$in: fetchedIds}}).data()
        this.tasks = sortBy(taskModelsForPath.filter(t => t.record() != null ), t => t.dueOn);

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

    taskUrlFor(record) {
      if (record.isA('discussion')) {
        return this.urlFor(record)+'/0';
      } else {
        return this.urlFor(record);
      }
    },

    taskExpiryFor(task) {
      if(task.dueOn === null) return -1;

      const timeLeft =  Date.parse(task.dueOn) - Date.now();
      if(timeLeft <= 0) return 0;

      const daysLeft = Math.floor(timeLeft / (60*60*1000) / 24);
      return daysLeft.toString();
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

    toggleHideVisible() {
      let visibleTasks = this.tasks.filter(this.filterTabs[this.activeFilter].filter);
      if(visibleTasks)
      {
        visibleTasks.forEach(task => {
          task.toggleHidden();
        });
      }
    },

    setFilter(tabId) { this.activeFilter = tabId; },

    routeQuery(o) {
      this.$router.replace(this.mergeQuery(o));
    },

    filterName(filter) {
      switch (filter) {
        case 'authored': return 'tasks.dropdown.authored';
        case 'all': return 'tasks.dropdown.all';
        default:
          return 'tasks.dropdown.assigned';
      }
    },

    getGroupBreadcrumbs(task) {
      let items = task.record().discussion().group().selfAndParents().map((group) => {
        return { text: group.name, exact: true, link: true, href: this.urlFor(group) }
      }).reverse()
      items.push({text: task.record().discussion().title, exact: true, link: true, href: this.taskUrlFor(task.record()) })

      return items
    }

  },

  computed: {
    filteredTasks() {
      return this.tasks.filter(this.filterTabs[this.activeFilter].filter);
    }
  },

  watch: {
    '$route.params'(){
      this.refresh();
    }
  }


};

</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024.px-0.px-sm-3

    v-container()
      v-row(:align="'center'")
        v-menu
          template(v-slot:activator="{ on, attrs }")
            v-btn.text-none.mr-2(v-on="on" v-bind="attrs" text)
              h1.text-h4.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="filterName($route.query.t)")
              common-icon(name="mdi-menu-down")
          v-list
            v-list-item(@click="routeQuery({t: 'assigned'})")
              v-list-item-title(v-t="'tasks.dropdown.assigned'")
            v-list-item(@click="routeQuery({t: 'authored'})")
              v-list-item-title(v-t="'tasks.dropdown.authored'")
            v-list-item(@click="routeQuery({t: 'all'})")
              v-list-item-title(v-t="'tasks.dropdown.all'")

        v-spacer
        v-col(:align="'right'")
          v-chip.mb-2(outlined @click="dialog = true")
            common-icon.mr-2(name="mdi-eye-off")
            span(v-t="'tasks.toggle_hide_all_button'")

          v-chip.mb-2.ml-3(outlined href="https://help.loomio.org/en/user_manual/threads/thread_admin/tasks.html" target="_blank")
            common-icon.mr-2(name="mdi-help-circle-outline")
            span(v-t="'common.help'")
            span :
            space
            span(v-t="'tasks.tasks'")
    template()
      v-dialog(v-model="dialog" :width="$vuetify.breakpoint.xs ? '90vw' : ' 40vw'")
        v-card.text-center
          v-card-title.justify-center(v-t="'tasks.toggle_hide_all_confirm.title'")
          v-card-text(v-t="'tasks.toggle_hide_all_confirm.description'")
          v-card-actions.justify-center
            v-btn(@click="dialog = false; toggleHideVisible()" color="red" v-t="'tasks.toggle_hide_all_confirm.button'")

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
    div.pa-3()
      template()
        v-card.ma-3(v-for="task in filteredTasks" :key="task.id" style="max-width: 90vw;")
          v-list-item(three-line)
            v-list-item-content.ml-2
              v-container.ma-0.pa-0
                v-row.ma-0.pa-0(:align="'center'")
                  v-btn(color="accent" icon @click="toggleDone(task)")
                    common-icon(v-if="task.done" name="mdi-checkbox-marked")
                    common-icon(v-else name="mdi-checkbox-blank-outline")

                  v-col.ma-0.pa-0(style="text-align: right")
                    div.text-overline(outlined v-if="taskExpiryFor(task) >= 0")
                      span(v-if="taskExpiryFor(task) === 0" v-t="'tasks.overdue'")
                      template(v-else)
                        span(v-t="'tasks.due_in' ")

                        span.mx-1(v-t="taskExpiryFor(task)")

                        span(v-if="taskExpiryFor(task) > 1" v-t="'tasks.day_plural' ")
                        span(v-else v-t=" 'tasks.day_singular'")

                  v-col.ma-0.pa-0(:align="'right'")
                    v-btn(text @click='toggleHidden(task)')
                      span.mr-2(v-t="task.hidden === false ? 'common.action.hide' : 'common.action.unhide'")
                      common-icon(v-if="task.hidden === false" name="mdi-eye-off")
                      common-icon(v-else name="mdi-eye")

              v-divider

              v-container.ml-1
                span.text-overline.text--secondary(v-t="'tasks.content'")
                p.ml-2(style="max-height: 30vh;") {{task.name}}

                span.text-overline.text--secondary(v-t="'tasks.origin_title'")
                v-breadcrumbs.ml-2.pa-0(:items="getGroupBreadcrumbs(task)" :divider="'>'")
                //this paragraph is to keep consistent spacing
                p

                div.ma-0.pa-0.text-overline.text--secondary
                  span(v-t="'tasks.author'")
                  v-row(:align="'center'")
                    v-col(:align="'right'")
                      span.mr-1 {{task.author().name}}
                      user-avatar.ml-1(:user='task.author()')

        p.ma-3(style="text-align: center" v-if="!loading && filteredTasks.length == 0" v-t="'tasks.no_tasks_to_display'")
</template>
