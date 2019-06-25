<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import UrlFor         from '@/mixins/url_for'
import truncate       from '@/mixins/truncate'
import GroupModalMixin from '@/mixins/group_modal'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [UrlFor, truncate, GroupModalMixin, WatchRecords]

  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    fragment: ''
    subgroups: []
    loading: true

  created: ->
    Records.groups.fetchByParent(@group).then =>
      @loading = false
      EventBus.$emit 'subgroupsLoaded', @group
      @watchRecords
        collections: ['groups']
        query: (store) =>
          @subgroups = store.groups.collection.chain().
                         find(parentId: @group.id).
                         simplesort('name').data()

  computed:
    filteredSubgroups: ->
      rx = RegExp(@fragment, 'i');
      @subgroups.filter((group) -> rx.test(group.name))

    canCreateSubgroups: ->
      AbilityService.canCreateSubgroups(@group)

  methods:
    startSubgroup: ->
      @openStartSubgroupModal(@group)

</script>

<template lang="pug">
.group-subgroups-panel
  v-toolbar(flat)
    v-toolbar-items
      v-text-field(solo flat append-icon="mdi-magnify" v-model="fragment" :label="$t('common.action.search')" clearable)
    v-spacer
    v-btn.subgroups-card__start(text color="primary" @click='startSubgroup()' v-if='canCreateSubgroups' v-t="'common.action.add_subgroup'")
    v-progress-linear(color="accent" indeterminate :active="loading" absolute bottom)

  v-list(avatar two-line)
    v-list-item.subgroups-card__list-item(v-for='group in filteredSubgroups', :key='group.id' :to='urlFor(group)')
      v-list-item-avatar.subgroups-card__list-item-logo
        group-avatar(:group="group" size="medium")
      v-list-item-content
        v-list-item-title {{ group.name }}
        v-list-item-subtitle {{ group.description }}
</template>
