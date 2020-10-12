<script lang="coffee">
import GroupService from '@/shared/services/group_service'
import Records        from '@/shared/services/records'
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'
import AppConfig      from '@/shared/services/app_config'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import AbilityService from '@/shared/services/ability_service'
import { uniq, debounce } from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    group: Object

  data: ->
    query: ''
    recipients: []
    reset: false
    saving: false
    users: []

  mounted: ->
    @fetchMemberships = debounce ->
      return unless @query

      @loading = true
      Records.memberships.fetch
        path: 'autocomplete'
        params:
          exclude_types: 'group'
          subgroups: 'all'
          q: @query
          group_id: @group.parentOrSelf().id
          per: 100
      .finally =>
        @loading = false
    , 300

    @watchRecords
      collections: ['memberships']
      query: (records) => @updateSuggestions()

  methods:
    inviteRecipients: ->
    newQuery: (query) ->
      @query = query
      @fetchMemberships()
      @updateSuggestions()

    newRecipients: (recipients) -> @recipients = recipients

    updateSuggestions: ->
      @users = @findUsers()

    findUsers: ->
      userIdsInGroup = Records.memberships.collection.
        chain().find(groupId: @group.id).
        data().map (m) -> m.userId
      membershipsChain = Records.memberships.collection.chain()
      membershipsChain = membershipsChain.find(groupId: { $in: @group.parentOrSelf().organisationIds() })
      membershipsChain = membershipsChain.find(userId: { $nin: userIdsInGroup })

      userIdsNotInGroup = uniq membershipsChain.data().map((m) -> m.userId)

      chain = Records.users.collection.chain()
      chain = chain.find(id: {$in: userIdsNotInGroup})


      if @query
        chain = chain.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}}
            {username: {'$regex': ["^#{@query}", "i"]}}
            {name: {'$regex': [" #{@query}", "i"]}}
          ]
      chain.data()

  computed:
    invitableGroups: ->
      @group.subgroups().filter (g) -> AbilityService.canAddMembersToGroup(g)


</script>
<template lang="pug">
.group-invitation-form
  .px-4.pt-4
    .d-flex.justify-space-between
      h1.headline(tabindex="-1" v-t="{path: 'announcement.send_group', args: {name: group.name} }")
      dismiss-modal-button
    recipients-autocomplete(
      :label="$t('announcement.form.group_announced.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :users="users"
      :reset="reset"
      @new-query="newQuery"
      @new-recipients="newRecipients")

    //- div(v-if="invitableGroups.length")
    //-   span(v-t="'announcement.any_other_groups'")
      //- div(v-for="group in invitableGroups" :key="group.id")
      //-   v-checkbox(:class="{'ml-4': !group.isParent()}" v-model="invitedGroupIds" :label="group.name" :value="group.id" hide-details)

    p invitation message

    .d-flex
      v-spacer
      v-btn(color="primary" :disabled="!recipients.length" @click="inviteRecipients" @loading="saving" v-t="'common.action.invite'")

</template>
