<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { map, sortBy, filter, debounce, without, uniq, find, compact } from 'lodash'
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
    isPage: Boolean
    user: Object

  data: ->
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    submitIsDisabled: false
    searchResults: []
    subscription: @discussion.group().parentOrSelf().subscription
    groupItems: []
    initialRecipients: []

  mounted: ->
    Records.users.fetchGroups()

    @watchRecords
      collections: ['groups', 'memberships']
      query: (records) =>
        @updateGroupItems()

  watch:
    'discussion.groupId':
      immediate: true
      handler: (groupId) ->
        @subscription = @discussion.group().parentOrSelf().subscription
        users = compact([@user]).map (u) ->
          id: u.id
          type: 'user'
          name: u.nameOrEmail()
          user: u
        @initialRecipients = []
        @initialRecipients = @initialRecipients.concat(users)
        @reset = !@reset

  methods:
    submit: ->
      actionName = if @discussion.id then 'updated' else 'created'
      @discussion.save()
      .then (data) =>
        discussionKey = data.discussions[0].key
        Records.discussions.findOrFetchById(discussionKey, {}, true).then (discussion) =>
          Flash.success("discussion_form.messages.#{actionName}")
          @$router.push @urlFor(discussion)
      .catch onError(@discussion)

    updateGroupItems: ->
      @groupItems = [{text: @$t('discussion_form.none_invite_only_thread'), value: null}].concat Session.user().groups().map (g) -> {text: g.fullName, value: g.id}

    updatePrivacy: ->
      @discussion.private = @discussion.privateDefaultValue()

    updateCount: ->
      Records.announcements.fetchNotificationsCount(@model).then (data) =>
        @notificationsCount = data.count

  computed:
    maxThreads: ->
      @subscription.max_threads

    threadCount: ->
      @discussion.group().parentOrSelf().orgDiscussionsCount

    maxThreadsReached: ->
      @maxThreads && @threadCount >= @maxThreads

    subscriptionActive: ->
      @subscription.active

    canStartThread: ->
      @subscriptionActive && !@maxThreadsReached

    showUpgradeMessage: ->
      !@discussion.id && !@canStartThread

    isMovingItems: ->
      @discussion.isForking

</script>

<template lang="pug">
.discussion-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline(v-observe-visibility="{callback: titleVisible}")
      span(v-if="isMovingItems" v-t="'discussion_form.moving_items_title'")
      template(v-else)
        span(v-if="!discussion.id" v-t="'discussion_form.new_discussion_title'")
        span(v-if="discussion.id" v-t="'discussion_form.edit_discussion_title'")
    v-spacer
    dismiss-modal-button(v-if="!isPage" aria-hidden='true')
    v-btn(v-if="isPage && discussion.id" icon  aria-hidden='true' :to="urlFor(discussion)")
      v-icon mdi-close
  .pa-4
    v-select(v-if="!discussion.id" v-model="discussion.groupId" :items="groupItems" :label="$t('common.group')")
    p.text--secondary.caption
      span(v-if="!discussion.groupId" v-t="'announcement.form.visible_to_guests'")
      span(v-if="discussion.groupId" v-t="{path: 'announcement.form.visible_to_group', args: {group: discussion.group().name}}")
    //- p discussion.recipientAudience {{discussion.recipientAudience}}
    //- p initialRecipients {{initialRecipients}}
    //- p userIds {{discussion.recipientUserIds}}
    //- p emails {{discussion.recipientEmails}}
    //- p audiences {{audiences}}
    recipients-autocomplete(
      v-if="!discussion.id"
      :label="$t(discussion.groupId ? 'action_dock.notify' : 'common.action.invite')"
      :placeholder="$t('announcement.form.discussion_announced.'+ (discussion.groupId ? 'notify_helptext' : 'helptext'))"
      :initial-recipients="initialRecipients"
      :hint="$t('announcement.form.placeholder')"
      :model="discussion"
      :reset="reset")

    div(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

    .discussion-form__group-selected(v-if='!showUpgradeMessage')
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input(:label="$t('discussion_form.title_label')" :placeholder="$t('discussion_form.title_placeholder')" v-model='discussion.title' maxlength='255' required)
      validation-errors(:subject='discussion', field='title')
      tags-field(:model="discussion")
      lmo-textarea(:model='discussion' field="description" :label="$t('discussion_form.context_label')" :placeholder="$t('discussion_form.context_placeholder')")

      common-notify-fields(:model="discussion")
      //- p.discussion-form__visibility
      v-card-actions
        v-spacer
        v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-if="!discussion.id" :loading="discussion.processing")
          span(v-t="'discussion_form.start_thread'")
        v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-if="discussion.id" :loading="discussion.processing")
          span(v-t="'common.action.save'")
</template>
