<script setup lang="js">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import { compact } from 'lodash-es';

import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import { useWatchRecords } from '@/composables/useWatchRecords';

const route = useRoute();
const { watchRecords } = useWatchRecords();

// Data
const templates = ref([]);
const actions = ref({});
const group = ref(null);
const groups = ref([]);
const returnTo = Session.returnTo();
const isSorting = ref(false);
const showHidden = ref(false);
const hasHiddenTemplates = ref(false);

// UrlFor replacement
const urlFor = (model, action, params) => {
  return LmoUrlService.route({ model, action, params });
};

const groupId = computed(() => {
  return parseInt(route.query.group_id);
});

const userIsAdmin = computed(() => {
  return group.value && group.value.adminsInclude(Session.user());
});

const canCreateTemplates = computed(() => {
  return userIsAdmin.value || (group.value && group.value.membersCanCreateTemplates && group.value.membersInclude(Session.user()));
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

const query = () => {
  if (!groupId.value) { return }

  group.value = Records.groups.findById(groupId.value);
  if (!group.value) { return }

  const findQuery = { groupId: groupId.value };
  if (!showHidden.value) { findQuery.discardedAt = null; }
  templates.value = Records.discussionTemplates.collection.chain().find(findQuery).simplesort('position').data();
  hasHiddenTemplates.value = Records.discussionTemplates.collection.find({ groupId: groupId.value, discardedAt: { $ne: null } }).length > 0;

  actions.value = {};
  templates.value.forEach((template, i) => {
    actions.value[i] = DiscussionTemplateService.actions(template, group.value);
  });
};

const sortEnded = () => {
  isSorting.value = false;
  setTimeout(() => {
    const ids = templates.value.map(p => p.id);
    Records.remote.post('discussion_templates/positions', {group_id: group.value.id, ids});
  });
};

// EventBus listeners
EventBus.$on('sortDiscussionTemplates', () => { isSorting.value = true; });
EventBus.$on('reloadDiscussionTemplates', () => { query(); });

onUnmounted(() => {
  EventBus.$off('sortDiscussionTemplates');
  EventBus.$off('reloadDiscussionTemplates');
});

// Mounted
onMounted(() => {
  Records.users.findOrFetchGroups();

  if (route.query.group_id) {
    Records.discussionTemplates.fetch({
      params: {
        group_id: route.query.group_id,
        per: 50
      }
    });
  }

  watchRecords({
    key: `discussionTemplates`,
    collections: ['discussionTemplates', 'groups'],
    query: () => query()
  });

  watchRecords({
    key: 'discussionTemplateGroups',
    collections: ['groups', 'memberships'],
    query: () => { groups.value = Session.user().parentGroups(); }
  });
});

watch(() => route.query.group_id, () => {
  if (!route.query.group_id) { return }
  Records.discussionTemplates.fetch({
    params: {
      group_id: route.query.group_id,
      per: 50
    }
  });
});

watch(showHidden, () => { query(); });
</script>
<template lang="pug">
.discussion-templates-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      //- Group chooser: shown when no group_id
      template(v-if="!groupId")
        v-card(:title="$t('discussion_template.start_a_new_discussion')")
          v-list(lines="two")
            v-list-subheader(v-t="'discussion_template.choose_group_for_templates'")
            v-list-item(
              v-for="group in groups"
              :key="group.id"
              :to="'/discussion_templates/?group_id='+group.id"
            )
              template(v-slot:prepend)
                v-icon.mr-2
                  group-avatar(:group="group")
              v-list-item-title {{group.name}}

            v-list-item.discussion-templates--direct-discussion(:to="'/d/new?return_to='+returnTo")
              template(v-slot:prepend)
                v-icon.mr-2 mdi-account-multiple
              v-list-item-title(v-t="'discussion_template.start_direct_discussion_from_blank'")

      //- Template list: shown when group_id is present
      template(v-if="groupId")
        .d-flex
          v-breadcrumbs(color="anchor" :items="breadcrumbs")
            template(v-slot:divider)
              common-icon(name="mdi-chevron-right")
        v-card(:title="$t('discussion_template.start_a_new_discussion')")
          template(v-slot:append v-if="canCreateTemplates")
            v-btn.text-primary(variant="text" size="small" :to="'/discussion_templates/new?group_id='+$route.query.group_id+'&return_to='+returnTo" v-t="'discussion_form.new_template'")
          v-alert.mx-4(type="info" variant="tonal")
            span(v-t="'discussion_template.these_are_templates_v2'")
            |
            help-link(path="en/user_manual/threads/starting_threads")

          v-list.append-sort-here(lines="two")
            template(v-if="isSorting")
              sortable-list(v-model:list="templates"  @sort-end="sortEnded" append-to=".append-sort-here"  lock-axis="y" axis="y")
                sortable-item(v-for="(template, index) in templates" :index="index" :key="template.id")
                  v-list-item(:key="template.id")
                    v-list-item-title {{template.processName || template.title}}
                    v-list-item-subtitle {{template.processSubtitle}}
                    template(v-slot:append)
                      div.handle(style="cursor: grab")
                        common-icon(name="mdi-drag-vertical")

            template(v-if="!isSorting")
              v-list-item.discussion-templates--template(
                v-for="(template, i) in templates"
                :key="template.id"
                :to="'/d/new?template_id='+template.id+'&group_id='+ $route.query.group_id + '&return_to='+returnTo"
              )
                v-list-item-title {{template.processName || template.title}}
                v-list-item-subtitle {{template.processSubtitle}}
                template(v-slot:append)
                  common-icon.text-disabled(v-if="template.discardedAt" name="mdi-eye-off")
                  action-menu(:actions='actions[i]' size="small" icon :name="$t('action_dock.more_actions')")

            .d-flex.justify-center.my-2(v-if="userIsAdmin && !showHidden")
              v-btn.text-medium-emphasis(variant="tonal" size="small" @click="showHidden = true" v-t="'discussion_template.more_templates'")
            template(v-if="userIsAdmin && showHidden")
              v-list-item(:to="'/discussion_templates/browse?group_id='+$route.query.group_id+'&return_to='+returnTo")
                v-list-item-title(v-t="'discussion_template.browse_example_templates'")
                template(v-slot:append)
                  common-icon(name="mdi-magnify")
              .d-flex.justify-center.my-2
                v-btn.text-medium-emphasis(variant="tonal" size="small" @click="showHidden = false" v-t="'discussion_template.fewer_templates'")
</template>
