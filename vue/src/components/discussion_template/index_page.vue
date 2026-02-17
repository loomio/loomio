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
const directTemplates = ref([]);
const hiddenTemplates = ref([]);
const actions = ref({});
const hiddenActions = ref({});
const group = ref(null);
const groups = ref([]);
const returnTo = Session.returnTo();
const isSorting = ref(false);
const showHidden = ref(false);
const hasHiddenTemplates = ref(false);
const hiddenAlert = ref(Session.user().hasExperienced('dismissDiscussionTemplatesAlert'));

const dismissAlert = () => {
  hiddenAlert.value = true;
  Records.users.saveExperience('dismissDiscussionTemplatesAlert');
};

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

const queryDirect = () => {
  const all = Records.discussionTemplates.collection.chain().find({ discardedAt: null }).simplesort('position').data();
  const blank = all.filter(t => t.key === 'blank');
  const rest = all.filter(t => t.key !== 'blank');
  directTemplates.value = [...blank, ...rest];
};

const query = () => {
  if (!groupId.value) { return }

  group.value = Records.groups.findById(groupId.value);
  if (!group.value) { return }

  templates.value = Records.discussionTemplates.collection.chain().find({ groupId: groupId.value, discardedAt: null }).simplesort('position').data();
  hiddenTemplates.value = Records.discussionTemplates.collection.chain().find({ groupId: groupId.value, discardedAt: { $ne: null } }).simplesort('position').data();
  hasHiddenTemplates.value = hiddenTemplates.value.length > 0;

  actions.value = {};
  templates.value.forEach((template, i) => {
    actions.value[i] = DiscussionTemplateService.actions(template, group.value);
  });

  hiddenActions.value = {};
  hiddenTemplates.value.forEach((template, i) => {
    hiddenActions.value[i] = DiscussionTemplateService.actions(template, group.value);
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
  } else {
    Records.discussionTemplates.fetch({ params: { per: 50 } }).then(() => {
      queryDirect();
    });
  }

  watchRecords({
    key: `discussionTemplates`,
    collections: ['discussionTemplates', 'groups', 'memberships'],
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
      //- Direct discussion templates: shown when no group_id
      template(v-if="!groupId")
        v-card(:title="$t('discussion_template.start_a_direct_discussion')")
          v-alert.mx-4(type="info" variant="tonal")
            span(v-t="'discussion_form.direct_discussion_hint'")
          v-list(lines="two")
            v-list-item(
              v-for="template in directTemplates"
              :key="template.id || template.key"
              :to="'/d/new?' + (template.id ? 'template_id='+template.id : 'template_key='+template.key) + '&return_to='+returnTo"
            )
              v-list-item-title {{template.processName || template.title}}
              v-list-item-subtitle {{template.group() && template.group().name || template.processSubtitle}}

      //- Template list: shown when group_id is present
      template(v-if="groupId")
        v-breadcrumbs(color="anchor" :items="breadcrumbs")
          template(v-slot:divider)
            common-icon(name="mdi-chevron-right")
        v-card(:title="$t('discussion_template.start_discussion')")
          v-alert.mx-4(v-if="userIsAdmin && !hiddenAlert" type="info" variant="tonal" closable @click:close="dismissAlert")
            span(v-t="'discussion_template.these_are_templates'")
            |  
            span(v-t="'common.templates_admin_hint'")

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
              .d-flex.justify-space-between.align-center
                v-list-subheader(v-t="'group_page.discussion_templates'")
                span.mr-4(v-if="canCreateTemplates")
                  v-btn(variant="tonal" size="small" :to="'/discussion_templates/browse?group_id='+$route.query.group_id+'&return_to='+returnTo")
                    span.text-medium-emphasis(v-t="'discussion_form.new_template'")
              v-list-item.discussion-templates--template(
                v-for="(template, i) in templates"
                :key="template.id"
                :to="'/d/new?template_id='+template.id+'&group_id='+ $route.query.group_id + '&return_to='+returnTo"
              )
                v-list-item-title {{template.processName || template.title}}
                v-list-item-subtitle {{template.processSubtitle}}
                template(v-slot:append)
                  action-menu(:actions='actions[i]' size="small" icon :name="$t('action_dock.more_actions')")

            .d-flex.justify-center.my-2(v-if="userIsAdmin && hasHiddenTemplates && !showHidden")
              v-btn.text-medium-emphasis(variant="text" size="small" @click="showHidden = true" )
                span(v-t="'discussion_template.show_hidden_templates'")

            template(v-if="userIsAdmin && showHidden")
              v-list-subheader(v-t="'discussion_template.hidden_templates'")
              v-list-item.discussion-templates--template(
                v-for="(template, i) in hiddenTemplates"
                :key="template.id"
                :to="'/d/new?template_id='+template.id+'&group_id='+ $route.query.group_id + '&return_to='+returnTo"
              )
                v-list-item-title {{template.processName || template.title}}
                v-list-item-subtitle {{template.processSubtitle}}
                template(v-slot:append)
                  action-menu(:actions='hiddenActions[i]' size="small" icon :name="$t('action_dock.more_actions')")
              .d-flex.justify-center.my-2
                v-btn.text-medium-emphasis(variant="text" size="small" @click="showHidden = false")
                  span(v-t="'discussion_template.show_fewer'")
</template>
