<script lang="coffee">
import GroupService from '@/shared/services/group_service'
import Records        from '@/shared/services/records'
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'
import AppConfig      from '@/shared/services/app_config'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
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
    groupIds: [@group.id]
    message: @$t('announcement.form.invitation_message')
    withMessage: false


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
      @saving = true
      Records.announcements.remote.post '',
        group_id: @group.id
        announcement:
          message: @message
          invited_group_ids: @groupIds
          recipients:
            emails: @recipients.filter((r) -> r.type == 'email').map((r) -> r.id)
            user_ids: @recipients.filter((r) -> r.type == 'user').map((r) -> r.id)

      .then (data) =>
        Flash.success('announcement.flash.success', { count: data.memberships.length })
        EventBus.$emit('closeModal')
      .finally =>
        @saving = false

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
      @group.parentOrSelf().selfAndSubgroups().filter (g) -> AbilityService.canAddMembersToGroup(g)


</script>
<template lang="pug">
.group-invitation-form
  .px-4.pt-4
    .d-flex.justify-space-between
      h1.headline(tabindex="-1" v-t="{path: 'announcement.send_group', args: {name: group.name} }")
      dismiss-modal-button
    div(v-if="invitingToGroup && !canInvite")
      .announcement-form__invite
        p(v-if="invitationsRemaining < 1" v-html="$t('announcement.form.no_invitations_remaining', {upgradeUrl: upgradeUrl, maxMembers: maxMembers})")
        p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")
    div(v-else)

      recipients-autocomplete(
        :label="$t('announcement.form.who_to_invite')"
        :placeholder="$t('announcement.form.placeholder')"
        :users="users"
        :reset="reset"
        @new-query="newQuery"
        @new-recipients="newRecipients")

      div.mb-4(v-if="invitableGroups.length")
        label.lmo-label Select groups
        //- v-label Select groups
        div(v-for="group in invitableGroups" :key="group.id")
          v-checkbox.invitation-form__select-groups(:class="{'ml-4': !group.isParent()}" v-model="groupIds" :label="group.name" :value="group.id" hide-details)

      v-textarea(v-model="message" :label="$t('announcement.form.invitation_message_label')" :placeholder="$t('announcement.form.invitation_message_placeholder')")

      //- a(@click="withMessage = !withMessage")
      //-   span(v-if="!withMessage") Include an invitation message
      //-   span(v-if="withMessage") Remove message

      v-card-actions
        v-spacer
        v-btn(color="primary" :disabled="!recipients.length" @click="inviteRecipients" :loading="saving")
          span(v-t="'common.action.invite'")

</template>
<style lang="css">

.lmo-label {
  color: rgba(0, 0, 0, 0.6);
  height: 20px;
  line-height: 20px;
  max-width: 133%;
  transform: translateY(-18px) scale(0.75);
  max-width: 90%;
  overflow: hidden;
  text-overflow: ellipsis;
  top: 6px;
  white-space: nowrap;
  pointer-events: none;
  font-size: 12px;
  line-height: 1;
  min-height: 8px;
  transition: 0.3s cubic-bezier(0.25, 0.8, 0.5, 1);
}

.invitation-form__select-groups {
  margin-top: 8px;
}

</style>
