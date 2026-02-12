<script setup lang="js">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import { compact } from 'lodash-es';

import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';

import { mdiCog } from '@mdi/js';

const route = useRoute();

// Data
const templates = ref([]);
const actions = ref({});
const group = ref(null);
const groups = ref([]);
const returnTo = Session.returnTo();
const isSorting = ref(false);
const showSettings = ref(false);
const watchedRecords = ref([]);

// WatchRecords replacement
const watchRecordsFunc = (options) => {
  const { collections, query, key } = options;
  const name = collections.concat(key || parseInt(Math.random() * 10000)).join('_');
  watchedRecords.value.push(name);
  Records.view({ name, collections, query });
};

// UrlFor replacement
const urlFor = (model, action, params) => {
  return LmoUrlService.route({ model, action, params });
};

// Computed
const hasGroupId = computed(() => {
  return !!route.query.group_id;
});

const userIsAdmin = computed(() => {
  return group.value && group.value.adminsInclude(Session.user());
});

const breadcrumbs = computed(() => {
  if (!group.value) { return []; }
  return compact([group.value.parentId && group.value.parent(), group.value]).map(g => {
    return {
      title: g.name,
      disabled: false,
      to: urlFor(g)
    };
  });
});

// Methods
const query = () => {
  if (!hasGroupId.value) { return; }
  group.value = Records.groups.findById(parseInt(route.query.group_id));
  templates.value = Records.discussionTemplates.collection.chain().find({
    groupId: parseInt(route.query.group_id),
    discardedAt: (showSettings.value && {$ne: null}) || null
  }).simplesort('position').data();

  if (group.value) {
    actions.value = {};
    templates.value.forEach((template, i) => {
      actions.value[i] = DiscussionTemplateService.actions(template, group.value);
    });
  }
};

const sortEnded = () => {
  isSorting.value = false;
  setTimeout(() => {
    const ids = templates.value.map(p => p.id || p.key);
    Records.remote.post('discussion_templates/positions', {group_id: group.value.id, ids});
  });
};

// EventBus listeners
EventBus.$on('sortDiscussionTemplates', () => { isSorting.value = true; });
EventBus.$on('reloadDiscussionTemplates', () => { query(); });

onUnmounted(() => {
  watchedRecords.value.forEach(name => delete Records.views[name]);
  EventBus.$off('sortDiscussionTemplates');
  EventBus.$off('reloadDiscussionTemplates');
});

// Mounted
onMounted(() => {
  if (hasGroupId.value) {
    Records.discussionTemplates.fetch({
      params: {
        group_id: route.query.group_id,
        per: 50
      }
    });

    watchRecordsFunc({
      key: `discussionTemplates${route.query.group_id}`,
      collections: ['discussionTemplates', 'groups'],
      query: () => query()
    });
  } else {
    Records.users.findOrFetchGroups();
    watchRecordsFunc({
      key: 'discussionTemplateGroups',
      collections: ['groups', 'memberships'],
      query: () => { groups.value = Session.user().parentGroups(); }
    });
  }
});

// Watchers
watch(() => route.query, () => { query(); });
watch(showSettings, () => { query(); });
</script>
<template lang="pug">
.discussion-templates-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      //- Group chooser: shown when no group_id
      template(v-if="!hasGroupId")
        v-card(:title="$t('discussion_template.start_a_new_discussion')")
          v-list(lines="two")
            v-list-subheader(v-t="'discussion_template.choose_group_for_templates'")
            v-list-item(
              v-for="group in groups"
              :key="group.id"
              :to="'/discussion_templates/?group_id='+group.id"
            )
              template(v-slot:prepend)
                group-avatar.mr-2(:group="group")
              v-list-item-title {{group.name}}

            v-divider.my-1

            v-list-item(:to="'/d/new?return_to='+returnTo")
              template(v-slot:prepend)
                v-icon.mr-2 mdi-account-multiple
              v-list-item-title(v-t="'discussion_template.start_direct_discussion'")

      //- Template list: shown when group_id is present
      template(v-if="hasGroupId")
        .d-flex
          v-breadcrumbs(color="anchor" :items="breadcrumbs")
            template(v-slot:divider)
              common-icon(name="mdi-chevron-right")
        v-card(:title="$t(showSettings ? 'discussion_template.hidden_templates' : 'discussion_template.start_a_new_discussion')")
          template(v-slot:append)
            v-btn(v-if="showSettings" icon @click="showSettings = false")
              common-icon(name="mdi-close")

          v-alert.mx-4(v-if="!showSettings && group && group.discussionsCount < 2" type="info" variant="tonal")
            span(v-t="'discussion_template.these_are_templates'")
            space
            help-link(path="en/user_manual/threads/starting_threads")

          v-list.append-sort-here(lines="two")
            .d-flex
              v-list-subheader(v-if="!showSettings" v-t="'templates.templates'")
              v-spacer
              div.mr-3(v-if="userIsAdmin")
                v-menu(v-if="!showSettings" offset-y)
                  template(v-slot:activator="{props}")
                    v-btn(:icon="mdiCog" variant="flat" v-bind="props" :title="$t('common.admin_menu')")
                  v-list
                    v-list-item(:to="'/discussion_templates/new?group_id='+$route.query.group_id+'&return_to='+returnTo")
                      v-list-item-title(v-t="'discussion_form.new_template'")
                    v-list-item(@click="showSettings = true")
                      v-list-item-title(v-t="'discussion_template.hidden_templates'")

            template(v-if="isSorting")
              sortable-list(v-model:list="templates"  @sort-end="sortEnded" append-to=".append-sort-here"  lock-axis="y" axis="y")
                sortable-item(v-for="(template, index) in templates" :index="index" :key="template.id || template.key")
                  v-list-item(:key="template.id")
                    v-list-item-title {{template.processName || template.title}}
                    v-list-item-subtitle {{template.processSubtitle}}
                    template(v-slot:append)
                      div.handle(style="cursor: grab")
                        common-icon(name="mdi-drag-vertical")

            template(v-if="!isSorting")
              v-list-item.discussion-templates--template(
                v-for="(template, i) in templates"
                :key="template.id || template.key"
                :to="'/d/new?' + (template.id ? 'template_id='+template.id : 'template_key='+template.key) + '&group_id='+ $route.query.group_id + '&return_to='+returnTo"
              )
                v-list-item-title {{template.processName || template.title}}
                v-list-item-subtitle {{template.processSubtitle}}
                template(v-slot:append)
                  action-menu(:actions='actions[i]' size="small" icon :name="$t('action_dock.more_actions')")

        .d-flex.justify-center.my-2(v-if="!showSettings && userIsAdmin")
          v-btn(:to="'/discussion_templates/browse?group_id=' + $route.query.group_id + '&return_to='+returnTo")
            span(v-t="'discussion_template.browse_public_templates'")
</template>
