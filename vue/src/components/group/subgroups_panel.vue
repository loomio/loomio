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
    subgroups: []

  created: ->
    Records.groups.fetchByParent(@group).then =>
      EventBus.$emit 'subgroupsLoaded', @group
      @watchRecords
        collections: ['groups']
        query: (store) =>
          @subgroups = store.groups.collection.chain().
                         find(parentId: @group.id).
                         simplesort('name').data()

  computed:
    canCreateSubgroups: ->
      AbilityService.canCreateSubgroups(@group)

  methods:
    startSubgroup: ->
      @openStartSubgroupModal(@group)

</script>

<template lang="pug">
.group-subgroups-panel
  v-toolbar(flat)
    v-spacer
    v-btn.subgroups-card__start(outline color="primary" @click='startSubgroup()' v-if='canCreateSubgroups' v-t="'common.action.add_subgroup'")
  v-list(avatar three-line)
    v-list-tile.subgroups-card__list-item(v-for='group in subgroups', :key='group.id')
      v-list-tile-avatar.subgroups-card__list-item-logo
        group-avatar(:group="group" size="medium")
      v-list-tile-content.subgroups-card__list-item-name
        router-link(:to='urlFor(group)') {{ group.name }}
        .caption.subgroups-card__list-item-description {{ truncate(group.description) }}
</template>
