<script lang="js">
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import Flash              from '@/shared/services/flash';
import EventBus           from '@/shared/services/event_bus';
import AbilityService     from '@/shared/services/ability_service';
import confirm_modal from "@/components/common/confirm_modal.vue";
import UrlFor from '@/mixins/url_for';
import WatchRecords from '@/mixins/watch_records';
import FormatDate from '@/mixins/format_date';
import {debounce, filter, forEach, groupBy, sortBy, uniq} from 'lodash-es';
import {mdiMagnify} from "@mdi/js";

export default {
  mixins: [UrlFor, WatchRecords, FormatDate],
  data() {
    return {
      records: {},
      tasks: [],
      loading: true,
      filterac: true,
      filters: [
        {name: 'todo', active: false, title: this.$t('tasks.filters.todo') },
        {name: 'done', active: false, title: this.$t('tasks.filters.done') },
        {name: 'assigned', active: false, title: this.$t('tasks.filters.assigned') },
        {name: 'created', active: false, title: this.$t('tasks.filters.created') },
        {name: 'hidden', active: false, title: this.$t('tasks.filters.hidden') },
      ],
      filterSelection: [],
      dialog: false
    };
  },

  mounted() {
    this.refresh();
  },

  methods: {
    refresh() {
      this.loading = true;

      this.filters.forEach(f => {
        f.active = this.$route.query[f.name] ?? false;
      })

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

    menuActions() {
      return {
        hideall: {
          icon: 'mdi-eye-off',
          name: this.$t('common.action.hide') + ' ' + this.$t('common.all'),
          menu: true,
          canPerform() { return true; },
          perform: () => { this.showConfirmationModal() }
        },
        unhideall: {
          icon: 'mdi-eye',
          name: this.$t('common.action.unhide') + ' ' + this.$t('common.all'),
          menu: true,
          canPerform() { return true; },
          perform: () => { this.showConfirmationModal() }
        }
      }
    },

    routeQuery(o) {
      this.$router.replace(this.mergeQuery(o));
    },

    getGroupBreadcrumbs(task) {
      let items = task.record().discussion().group().selfAndParents().map((group) => {
        return { title: group.name, exact: true, link: true, href: this.urlFor(group) }
      }).reverse()
      items.push({title: task.record().discussion().title, exact: true, link: true, href: this.taskUrlFor(task.record()) })

      return items
    },

    applyFilters(newFilters) {
      let queryMod = {};
      this.filters.map((f) => { queryMod[f.name] = false })

      newFilters.forEach((f) => {
        queryMod[f.name] = true;
      })

      this.routeQuery(queryMod);

    },

    showConfirmationModal() {
      console.log('received');
      this.dialog = true;
    }
  },


  computed: {
    filteredTasks() {
      return this.tasks;
    }
  },

  watch: {
    '$route.params'(){
      this.refresh();
    },
  }


};

</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024.px-0.px-sm-3

    //header
    v-row(:align="'center'").ml-3
      h1.text-h4.my-4(v-t="'tasks.tasks'")
      v-spacer
      v-chip(outlined href="https://help.loomio.org/en/user_manual/threads/thread_admin/tasks.html" target="_blank")
        common-icon.mr-2(name="mdi-help-circle-outline")
        span(v-t="'common.help'")
      action-menu.ml-5.mr-5(:actions="menuActions()" :menuIcon="'mdi-dots-horizontal'" icon)

    v-container
      v-col(justify="center")
        //filter bar
        v-select(multiple clearable return-object chips :label="$t('tasks.filterlabel')" v-model="filterSelection" :items="filters" @update:modelValue="applyFilters")


        //task entries
        v-card.mb-3(v-for="task in filteredTasks" :key="task.id" style="max-width: 90vw;")
          v-list-item(lines="three")
            v-container.ma-0.pa-0

              v-row.ma-10.mt-0
                p.ma-3(style="max-height: 30vh;") {{task.name}}

              v-row(:align="'center'" no-gutters)
                v-col(align="left")
                  v-btn(variant="plain" color="accent" @click="toggleDone(task)")
                    span.mr-1(v-t="$t('tasks.checkbox_title') + ':'")
                    common-icon(v-if="task.done" name="mdi-checkbox-marked")
                    common-icon(v-else name="mdi-checkbox-blank-outline")


                v-col(align="center")
                  div.text-overline(outlined v-if="taskExpiryFor(task) >= 0")
                    span(v-if="taskExpiryFor(task) === 0" v-t="'tasks.overdue'")
                    template(v-else)
                      span(v-t="'tasks.due_in' ")

                      span.mx-1(v-t="taskExpiryFor(task)")

                      span(v-if="taskExpiryFor(task) > 1" v-t="'tasks.day_plural' ")
                      span(v-else v-t=" 'tasks.day_singular'")

                v-col(align="right")
                  v-btn(variant="plain" @click='toggleHidden(task)')
                    span.mr-2(v-t="task.hidden === false ? 'common.action.hide' : 'common.action.unhide'")
                    common-icon(v-if="task.hidden === false" name="mdi-eye-off")
                    common-icon(v-else name="mdi-eye")

              v-divider.pa-2
              v-row.ms-0
                v-col(:align="'left'")
                  v-breadcrumbs.ma-0.pa-0(:items="getGroupBreadcrumbs(task)" :divider="'>'")
                v-col(:align="'right'")
                  span.mr-1 {{task.author().name}}
                  user-avatar.ml-1(:user='task.author()')

        //text when empty
        p.ma-3(style="text-align: center" v-if="!loading && filteredTasks.length == 0" v-t="'tasks.no_tasks_to_display'")
</template>
