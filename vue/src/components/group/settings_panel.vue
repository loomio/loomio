<script setup lang="js">
import { computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import GroupService from '@/shared/services/group_service';

const route = useRoute();
const { t } = useI18n();

const group = computed(() => Records.groups.fuzzyFind(route.params.key));

onMounted(() => {
  if (group.value) {
    EventBus.$emit('currentComponent', {
      page: 'groupPage',
      title: group.value.name,
      group: group.value
    });
  }
});

const allActions = computed(() => (group.value ? GroupService.actions(group.value) : {}));

const DESCRIPTIONS = {
  edit_group: 'group_settings_panel.edit_group_description',
  edit_tags: 'group_settings_panel.edit_tags_description',
  manage_subscription: 'group_settings_panel.manage_subscription_description',
  change_volume: 'group_settings_panel.change_volume_description',
  email_group: 'group_settings_panel.email_group_description',
  group_stats: 'group_settings_panel.group_stats_description',
  become_coordinator: 'group_settings_panel.become_coordinator_description',
  chatbots: 'group_settings_panel.chatbots_description',
  api_docs: 'group_settings_panel.api_docs_description',
  export_data: 'group_settings_panel.export_data_description',
  leave_group: 'group_settings_panel.leave_group_description',
  destroy_group: 'group_settings_panel.destroy_group_description'
};

function buildItems(keys, { danger = false } = {}) {
  const actions = allActions.value;
  return keys
    .map(key => {
      const action = actions[key];
      if (!action || !action.menu || !action.canPerform()) { return null; }
      const title = action.nameArgs ? t(action.name, action.nameArgs()) : t(action.name);
      return {
        key,
        title,
        description: DESCRIPTIONS[key] ? t(DESCRIPTIONS[key]) : '',
        icon: action.icon === 'mdi-connection' ? 'mdi-robot-outline' : action.icon,
        to: action.to ? action.to() : undefined,
        href: action.href ? action.href() : undefined,
        perform: action.perform,
        danger
      };
    })
    .filter(Boolean);
}

const sections = computed(() => [
  {
    key: 'admin',
    title: t('group_settings_panel.group_administration'),
    items: buildItems(['edit_group', 'edit_tags', 'manage_subscription'])
  },
  {
    key: 'membership',
    title: t('group_settings_panel.your_membership'),
    items: buildItems(['change_volume', 'email_group', 'group_stats', 'become_coordinator'])
  },
  {
    key: 'integrations',
    title: t('group_settings_panel.integrations_and_data'),
    items: buildItems(['chatbots', 'api_docs', 'export_data'])
  },
  {
    key: 'danger',
    title: t('group_settings_panel.leave_or_delete'),
    items: buildItems(['leave_group', 'destroy_group'], { danger: true })
  }
].filter(section => section.items.length > 0));

function trigger(item) {
  if (!item.to && !item.href && typeof item.perform === 'function') {
    item.perform();
  }
}
</script>

<template lang="pug">
.group-settings-panel.pt-4(v-if="group")
  v-card.mb-4(
    v-for="section in sections"
    :key="section.key"
    variant="flat"
  )
    .px-5.pt-4.pb-1.text-overline.text-medium-emphasis {{ section.title }}
    v-list.px-2.pb-2(lines="two")
      v-list-item(
        v-for="item in section.items"
        :key="item.key"
        :class="['action-dock__button--' + item.key, item.danger ? 'text-error' : '']"
        :to="item.to"
        :href="item.href"
        @click="trigger(item)"
      )
        template(#prepend)
          common-icon.mr-3(:name="item.icon" :color="item.danger ? 'error' : undefined")
        v-list-item-title(:class="item.danger ? 'text-error' : ''") {{ item.title }}
        v-list-item-subtitle.text-wrap {{ item.description }}
        template(#append)
          common-icon(name="mdi-chevron-right" size="small")
</template>
