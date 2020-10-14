<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { map, sortBy, filter, debounce, without, uniq } from 'lodash'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    discussion: Object
    close: Function
    isPage: Boolean

  data: ->
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    submitIsDisabled: false
    searchResults: []
    query: ''
    recipients: []
    groups: []
    users: []
    announce: true
    canAnnounce: true

  mounted: ->
    @recipients = @initialRecipients

    @watchRecords
      collections: ['groups', 'memberships']
      query: (records) => @updateSuggestions()

  watch:
    query: ->
      @fetchMemberships()
      @updateSuggestions()

    'discussion.groupId':
      immediate: true
      handler: (groupId) ->
        @fetchMemberships()
        @updateSuggestions()
        if groupId
          @canAnnounce = !!(@discussion.group().adminsInclude(Session.user()) || @discussion.group().membersCanAnnounce)
          @announce = @canAnnounce
        else
          @announce = false
          @canAnnounce = false

  methods:
    fetchMemberships: debounce ->
      return unless @query
      emails = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])
      return if emails.length

      @loading = true
      Records.memberships.fetch
        path: 'autocomplete'
        params:
          exclude_types: 'group'
          q: @query
          group_id: @discussion.groupId
          per: 50
      .finally =>
        @loading = false
    , 300

    newQuery: (query) ->
      @query = query
    findGroups: ->
      return [] if @recipients.find((i) -> i.type == 'group')
      allGroups = if @discussion.groupId
        @discussion.group().parentOrSelf().selfAndSubgroups()
      else
        Session.user().groups()
      allGroups = allGroups.filter (group) -> AbilityService.canStartThread(group)

      chain = Records.groups.collection.chain().
                   find(id: {$in: map(allGroups, 'id')}).
                   simplesort('openDiscussionsCount', true)

      if @query
        chain = chain.find(name: {'$regex': ["^#{@query}", 'i']})
      chain.data()

    findUsers: ->
      chain = Records.users.collection.chain()

      if @discussion.groupId
        chain = chain.find(id: {$in: @discussion.group().memberIds()})

      chain = chain.find(id: {$nin: [Session.user().id]})

      if @query
        chain = chain.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}}
            {username: {'$regex': ["^#{@query}", "i"]}}
            {name: {'$regex': [" #{@query}", "i"]}}
          ]

      chain.data()

    updateSuggestions: ->
      @users = @findUsers()
      @groups = @findGroups()

    submit: ->
      actionName = if @discussion.isNew() then 'created' else 'updated'
      @discussion.save()
      .then (data) =>
        discussionKey = data.discussions[0].key
        Records.discussions.findOrFetchById(discussionKey, {}, true).then (discussion) =>
          Flash.success("discussion_form.messages.#{actionName}")
          @$router.push @urlFor(discussion)
      .catch onError(@discussion)

    updatePrivacy: ->
      @discussion.private = @discussion.privateDefaultValue()

    newRecipients: (val) ->
      @recipients = val
      @discussion.groupId = (val.find((i) -> i.type=='group') || {}).id
      @discussion.recipientUserIds = map filter(val, (o) -> o.type == 'user'), 'id'
      @discussion.recipientEmails = map filter(val, (o) -> o.type == 'email'), 'name'

  computed:
    notificationsCount: ->
      guests = @recipients.filter (o) =>
        o.type == 'user' && (!@discussion.groupId || Records.memberships.find(userId: o.id, groupId: @discussion.groupId).length == 0)
      .length
      emails = @recipients.filter((o) => o.type == 'email').length
      members = if @discussion.groupId && @announce then @discussion.group().acceptedMembershipsCount else 0
      guests + emails + members

    initialRecipients: ->
      if @discussion.groupId
        [{id: @discussion.groupId, type: 'group', name: @discussion.group().name, group: @discussion.group()}]
      else
        []

    maxThreads: ->
      @discussion.group().parentOrSelf().subscription.max_threads

    threadCount: ->
      @discussion.group().parentOrSelf().orgDiscussionsCount

    maxThreadsReached: ->
      @maxThreads && @threadCount >= @maxThreads

    subscriptionActive: ->
      @discussion.group().parentOrSelf().subscription.active

    canStartThread: ->
      @subscriptionActive && !@maxThreadsReached

    showUpgradeMessage: ->
      @discussion.isNew() && !@canStartThread

    isMovingItems: ->
      @discussion.isForking

</script>

<template lang="pug">
.discussion-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline
      span(v-if="isMovingItems" v-t="'discussion_form.moving_items_title'")
      template(v-else)
        span(v-if="discussion.isNew()" v-t="'discussion_form.new_discussion_title'")
        span(v-if="!discussion.isNew()" v-t="'discussion_form.edit_discussion_title'")
    v-spacer
    dismiss-modal-button(v-if="!isPage" aria-hidden='true' :close='close')
    v-btn(v-if="isPage && !discussion.isNew()" icon  aria-hidden='true' :to="urlFor(discussion)")
      v-icon mdi-close
  .pa-4
    //- .lmo-hint-text(v-t="'group_page.discussions_placeholder'" v-show='discussion.isNew() && !isMovingItems')
    //- discussion-privacy-badge.mb-2(:discussion="discussion" no-link)
    .body-1(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

    .discussion-form__group-selected(v-if='!showUpgradeMessage')
      recipients-autocomplete(
        v-if="discussion.isNew()"
        :label="$t('discussion_form.to')"
        :placeholder="$t('announcement.form.discussion_announced.helptext')"
        :groups="groups"
        :users="users"
        :initial-recipients="initialRecipients"
        @new-query="newQuery"
        @new-recipients="newRecipients")
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input.text-h5(:label="$t('discussion_form.title_label')" :placeholder="$t('discussion_form.title_placeholder')" v-model='discussion.title' maxlength='255')
      validation-errors(:subject='discussion', field='title')
      lmo-textarea(:model='discussion' field="description" :label="$t('discussion_form.context_label')" :placeholder="$t('discussion_form.context_placeholder')")
      v-checkbox(:label="$t('discussion_form.notify_group')" v-model="announce" :disabled="!canAnnounce")
      .caption(v-if="notificationsCount != 1" v-t="{ path: 'poll_common_notify_group.members_count', args: { count: notificationsCount } }")
      .caption(v-else v-t="'discussion_form.one_person_notified'")


      v-card-actions
        v-spacer
        v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-t="'discussion_form.start_thread'" v-if="discussion.isNew()")
        v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-t="'common.action.save'" v-if="!discussion.isNew()")
</template>
