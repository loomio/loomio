<script lang="coffee">
import GroupService from '@/shared/services/group_service'
import Records        from '@/shared/services/records'
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'
export default
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    actions: {}
  created: ->
    Records.groups.remote.fetchById(@group.id)
    EventBus.$emit 'currentComponent',
      page: 'groupPage'
      title: @group.name
      group: @group
      search:
        placeholder: @$t('navbar.search_members', name: @group.parentOrSelf().name)
    @watchRecords
      collections: ['memberships']
      query: =>
        @actions = GroupService.actions(@group, @)
        @membership = @group.membershipFor(Session.user())
</script>
<template lang="pug">
div
  group-subscription-card(:group="group")
  v-card.mt-2(outlined)
    v-list.settings-panel
      v-list-item(v-for="(action, name) in actions" :key="name" @click="action.perform()" v-if='action.canPerform()' :class="'group-page-actions__' + name")
        v-list-item-avatar
          v-icon {{action.icon}}
        v-list-item-title(v-t="action.name")
</template>
