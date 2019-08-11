<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import GroupModalMixin from '@/mixins/group_modal'
import { truncate } from 'lodash'

export default
  mixins: [GroupModalMixin]

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

    stripDescription: (description) ->
      truncate (description).replace(///<[^>]*>?///gm, ''), 50
</script>

<template lang="pug">
v-card.group-subgroups-panel
  v-toolbar(flat)
    v-btn.subgroups-card__start(color="primary" @click='startSubgroup()' v-if='canCreateSubgroups' v-t="'common.action.add_subgroup'")
    v-progress-linear(color="accent" indeterminate :active="loading" absolute bottom)
  v-divider

  v-list(avatar two-line)
    v-list-item.subgroups-card__list-item(v-for='group in filteredSubgroups', :key='group.id' :to='urlFor(group)')
      v-list-item-avatar.subgroups-card__list-item-logo
        group-avatar(:group="group" size="28px")
      v-list-item-content
        v-list-item-title {{ group.name }}
        v-list-item-subtitle {{ stripDescription(group.description) }}
</template>
