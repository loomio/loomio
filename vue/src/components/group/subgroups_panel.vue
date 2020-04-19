<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import GroupModalMixin from '@/mixins/group_modal'
import { debounce, some, every } from 'lodash'

export default
  data: ->
    group: null
    loading: true

  created: ->
    Records.groups.findOrFetch(@$route.params.key).then (group) =>
      @group = group

      EventBus.$emit 'currentComponent',
        page: 'groupPage'
        title: @group.name
        group: @group

      Records.groups.fetchByParent(@group).then =>
        @loading = false
        EventBus.$emit 'subgroupsLoaded', @group

      @watchRecords
        collections: ['memberships', 'groups']
        query: @findRecords

      @findRecords()

  computed:
    canCreateSubgroups: ->
      AbilityService.canCreateSubgroups(@group)

  methods:
    onQueryInput: (val) ->
      @$router.replace(@mergeQuery(q: val))

    findRecords: ->
      chain = Records.groups.collection.chain().
                     find(parentId: @group.id).
                     simplesort('name')

      if @$route.query.q
        chain = chain.where (group) =>
          some [group.name, group.description], (field) =>
            RegExp(@$route.query.q, "i").test(field)

      @subgroups = chain.data()

    startSubgroup: ->
      EventBus.$emit('openModal',
                      component: 'GroupNewForm',
                      props: {
                        parentId: @group.id
                      })


    stripDescription: (description) -> (description || '').replace(///<[^>]*>?///gm, '')

  watch:
    '$route.query': 'findRecords'
</script>
<template lang="pug">
div(v-if="group")
  v-layout.my-2(align-center wrap)
    v-text-field.mr-2(clearable hide-details solo :value="$route.query.q" @input="onQueryInput" :placeholder="$t('subgroups_panel.search_subgroups_of_name', {name: group.name})" append-icon="mdi-magnify")
    v-btn.subgroups-card__start(color="primary" @click='startSubgroup()' v-if='canCreateSubgroups' v-t="'common.action.add_subgroup'")

  v-card.group-subgroups-panel(outlined)
    p.text-center.pa-4(v-if="!loading && !subgroups.length" v-t="'common.no_results_found'")
    v-list(v-else avatar three-line)
      v-list-item.subgroups-card__list-item(v-if="group.subgroups().length > 0" :to="urlFor(group)+'?subgroups=none'")
        v-list-item-avatar.subgroups-card__list-item-logo
          group-avatar(:group="group" size="28px")
        v-list-item-content
          v-list-item-title(v-t="{path: 'subgroups_panel.group_without_subgroups', args: {name: group.name}}")
          v-list-item-subtitle {{ stripDescription(group.description) }}
      v-list-item.subgroups-card__list-item(v-for='group in subgroups', :key='group.id' :to='urlFor(group)')
        v-list-item-avatar.subgroups-card__list-item-logo
          group-avatar(:group="group" size="28px")
        v-list-item-content
          v-list-item-title {{ group.name }}
          v-list-item-subtitle {{ stripDescription(group.description) }}
</template>
