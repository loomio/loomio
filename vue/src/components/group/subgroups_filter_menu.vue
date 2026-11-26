<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { sortBy } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import Session from '@/shared/services/session';
import GroupAbility from '@/shared/abilities/group_ability';

const { group, selected } = defineProps({
  group: Object,
  selected: { type: String, default: null }
});
const emit = defineEmits(['select']);
const { t } = useI18n();
const open = ref(false);
const filter = ref('');

const active = computed(() => selected === 'mine' || selected === 'all');
const label = computed(() => {
  if (selected === 'mine') { return t('group_cards.my_subgroups'); }
  if (selected === 'all') { return t('group_cards.all_subgroups'); }
  return t('group_page.subgroups');
});
const visibleSubgroups = computed(() => {
  if (!group || typeof group.subgroups !== 'function') { return []; }
  const user = Session.user();
  return sortBy(
    group.subgroups().filter(sg => !sg.isDiscarded() && (sg.membershipFor(user) || GroupAbility.canShow(sg))),
    'name'
  );
});
const filteredSubgroups = computed(() => {
  const query = filter.value.trim().toLowerCase();
  if (!query) { return visibleSubgroups.value; }
  return visibleSubgroups.value.filter(sg => (sg.name || '').toLowerCase().includes(query));
});

watch(open, isOpen => {
  if (!isOpen) { filter.value = ''; }
});

function selectOption(val) {
  open.value = false;
  emit('select', val);
}

function subgroupUrl(subgroup) {
  return subgroup.handle ? `/${subgroup.handle}` : `/g/${subgroup.key}`;
}
</script>

<template lang="pug">
v-menu(v-if="group && group.subgroupsCount > 0" v-model="open" :close-on-content-click="false")
  template(#activator="{ props }")
    v-btn.subgroups-filter-menu__button(
      v-bind="props"
      variant="tonal"
      :color="active ? 'primary' : undefined"
      :class="{ 'text-medium-emphasis': !active }"
    )
      span {{ label }}
      common-icon(name="mdi-menu-down" color="currentColor")
  v-card(min-width="240" max-width="360")
    .pa-2(v-if="visibleSubgroups.length > 8")
      v-text-field(
        v-model="filter"
        :placeholder="t('group_cards.filter_subgroups')"
        autofocus
        density="compact"
        hide-details
        :prepend-inner-icon="mdiMagnify"
        variant="outlined"
      )
    v-list(density="compact" max-height="60vh")
      v-list-item.subgroups-filter-menu__none(:active="!active" @click="selectOption(null)")
        v-list-item-title {{ t('group_cards.this_group_only') }}
      v-list-item.subgroups-filter-menu__mine(:active="selected === 'mine'" @click="selectOption('mine')")
        v-list-item-title {{ t('group_cards.my_subgroups') }}
      v-list-item.subgroups-filter-menu__all(:active="selected === 'all'" @click="selectOption('all')")
        v-list-item-title {{ t('group_cards.all_subgroups') }}
      template(v-if="filteredSubgroups.length > 0")
        v-divider.my-1
        v-list-item.subgroups-filter-menu__subgroup(
          v-for="subgroup in filteredSubgroups"
          :key="subgroup.id"
          :to="subgroupUrl(subgroup)"
          @click="open = false"
        )
          v-list-item-title {{ subgroup.name }}
</template>
