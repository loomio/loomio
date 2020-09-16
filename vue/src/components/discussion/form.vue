<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { map, sortBy, filter, debounce, without } from 'lodash'
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
    groupSelectOptions: []
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    allGroups: []
    parentGroup: null
    submitIsDisabled: false
    searchResults: []
    excludedUserIds: [Session.user().id]
    query: ''
    recipients: []

  mounted: ->
    @recipients = @initialRecipients
    @parentGroup = @discussion.group().parentOrSelf()
    Records.memberships.fetchByGroup(@discussion.groupId, per: 100)

    @watchRecords
      collections: ['groups']
      query: (store) =>
        parentGroup = @discussion.group().parentOrSelf()
        @allGroups = [parentGroup].concat(parentGroup.subgroups())

  methods:
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
      groupId = (val.find((i) -> i.type=='group') || {}).id
      if groupId
        @discussion.groupId = groupId
        @discussion.visibleTo = "group"
      else
        @discussion.groupId = @parentGroup.id
        @discussion.visibleTo = "discussion"

      # do some stuff with user_ids and emails

  computed:
    initialRecipients: ->
      if @discussion.visibleTo == 'group' and @discussion.group()
        [{id: @discussion.groupId, type: 'group', name: @discussion.group().name}]
      else
        []

    availableGroups: ->
      if @recipients.find((i) -> i.type == 'group')
        []
      else
        filter(@allGroups, (group) -> AbilityService.canStartThread(group))

    visibleTos: ->
      @discussion.availableVisibleTos().map (value) =>
        text = switch value
          when 'discussion'
            @$t("discussion_form.visible_to_discussion")
          when 'group'
            @$t("discussion_form.visible_to_group")
          when 'parent_group'
            @discussion.group().parent().name
          when 'public'
            @$t("discussion_form.visible_to_public")
        {text, value}

    maxThreads: ->
      return null unless @discussion.group()
      @discussion.group().parentOrSelf().subscription.max_threads

    threadCount: ->
      return unless @discussion.group()
      @discussion.group().parentOrSelf().orgDiscussionsCount

    maxThreadsReached: ->
      @maxThreads && @threadCount >= @maxThreads

    subscriptionActive: ->
      return true unless @discussion.group()
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
    discussion-privacy-badge.pa-4(:discussion="discussion")
    .body-1(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

    .discussion-form__group-selected(v-if='discussion.groupId && discussion.group() && !showUpgradeMessage')
      recipients-autocomplete(
        label="invite"
        placeholder="enter names or email addresses of people to invite to the thread"
        show-groups
        :available-groups="availableGroups"
        :group="discussion.group()"
        :initial-recipients="initialRecipients"
        :excluded-user-ids="excludedUserIds"
        @new-recipients="newRecipients")
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input.text-h5(:label="$t('discussion_form.title_label')" :placeholder="$t('discussion_form.title_placeholder')" v-model='discussion.title' maxlength='255')
      validation-errors(:subject='discussion', field='title')
      lmo-textarea(:model='discussion' field="description" :label="$t('discussion_form.context_label')" :placeholder="$t('discussion_form.context_placeholder')")
        template(v-slot:actions)
          v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled || !discussion.groupId" v-t="'discussion_form.start_thread'" v-if="discussion.isNew()")
          v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-t="'common.action.save'" v-if="!discussion.isNew()")
</template>
