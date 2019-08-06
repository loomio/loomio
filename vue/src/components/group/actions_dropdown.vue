<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import GroupService from '@/shared/services/group_service'
export default
  props:
    group: Object

  data: ->
    actions: {}

  created: ->
    @watchRecords
      collections: ['memberships']
      query: =>
        @actions = GroupService.actions(@group, @)
        @membership = @group.membershipFor(Session.user())
</script>

<template lang="pug">
v-menu.group-page-actions.lmo-no-print(v-if="membership" offset-y)
  template(v-slot:activator="{on}")
    v-btn.group-page-actions__button(text v-on="on" v-t="'group_page.options.label'")
  v-list.group-actions-dropdown__menu-content

    v-list-item(v-for="(action, name) in actions" :key="name" @click="action.perform()" v-if='action.canPerform()' :class="'group-page-actions__' + name")
      v-list-item-title(v-t="action.name")
</template>
