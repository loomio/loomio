<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import ThreadService from '@/shared/services/thread_service'
import { map, sortBy, filter, debounce, without, uniq, find, compact } from 'lodash'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import I18n from '@/i18n.coffee'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import ThreadTemplateHelpPanel from '@/components/thread_template/help_panel'

export default
  components: {RecipientsAutocomplete, ThreadTemplateHelpPanel}

  props:
    discussion: Object
    isPage: Boolean
    user: Object

  data: ->
    tab: 0
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    submitIsDisabled: false
    searchResults: []
    subscription: @discussion.group().parentOrSelf().subscription
    groupItems: []
    initialRecipients: []
    discussionTemplate: null

  mounted: ->
    Records.users.fetchGroups()
    Records.pollTemplates.fetchAll(@discussion.groupId)
    Records.discussionTemplates.findOrFetchByKeyOrId(@discussion.discussionTemplateKeyOrId()).then (template) =>
      @discussionTemplate = template

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
        @discussion.private = @discussion.privateDefaultValue()
        @reset = !@reset

  methods:
    submit: ->
      actionName = if @discussion.id then 'updated' else 'created'
      @discussion.save()
      .then (data) =>
        discussionKey = data.discussions[0].key
        EventBus.$emit('closeModal')
        Records.discussions.findOrFetchById(discussionKey, {}, true).then (discussion) =>
          Flash.success("discussion_form.messages.#{actionName}")
          @$router.push @urlFor(discussion)
      .catch (error) => true

    updateGroupItems: ->
      @groupItems = [{text: @$t('discussion_form.none_invite_only_thread'), value: null}].concat Session.user().groups().map (g) -> {text: g.fullName, value: g.id}

    openEditLayout: ->
      ThreadService.actions(@discussion, @)['edit_arrangement'].perform()

  computed:
    titlePlaceholder: ->
      if @discussionTemplate && @discussionTemplate.titlePlaceholder
        I18n.t('common.prefix_eg', {val: @discussionTemplate.titlePlaceholder})
      else
        I18n.t('discussion_form.title_placeholder')

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
      @discussion.forkedEventIds.length

</script>

<template lang="pug">
.discussion-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.text-h4(v-observe-visibility="{callback: titleVisible}")
      span(v-if="isMovingItems" v-t="'discussion_form.moving_items_title'")
      template(v-else)
        span(v-if="discussionTemplate && !discussion.id" v-t="{path: 'discussion_form.new_thread_from_template', args: {process_name: discussionTemplate.processName}}")
        span(v-if="!discussionTemplate && !discussion.id" v-t="'discussion_form.new_discussion_title'")
        span(v-if="discussion.id" v-t="'discussion_form.edit_discussion_title'")
    v-spacer
    dismiss-modal-button(
      v-if="!isPage"
      aria-hidden='true'
      :model="discussion")
    v-btn(
      v-if="isPage && discussion.id"
      icon
      aria-hidden='true'
      :to="urlFor(discussion)"
    )
      v-icon mdi-close
    v-btn.back-button(v-if="isPage && $route.query.return_to" icon :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
      v-icon mdi-close


  .pa-4
    thread-template-help-panel(v-if="discussionTemplate" :discussion-template="discussionTemplate")

    v-select.pb-4(
      :disabled="!!discussion.id"
      v-model="discussion.groupId"
      :items="groupItems"
      :label="$t('common.group')"
      :hint="discussion.groupId ? $t('announcement.form.visible_to_group', {group: discussion.group().name}) : $t('announcement.form.visible_to_guests')"
      persistent-hint
    )

    div(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")
    .discussion-form__group-selected(v-else)
      tags-field(:model="discussion")

      recipients-autocomplete(
        v-if="!discussion.id"
        :label="$t(discussion.groupId ? 'action_dock.notify' : 'common.action.invite')"
        :placeholder="$t('announcement.form.discussion_announced.'+ (discussion.groupId ? 'notify_helptext' : 'helptext'))"
        :initial-recipients="initialRecipients"
        :hint="$t('announcement.form.placeholder')"
        :model="discussion"
        :reset="reset"
      )

      v-text-field#discussion-title.discussion-form__title-input(
        :label="$t('discussion_form.title_label')"
        :placeholder="titlePlaceholder"
        v-model='discussion.title' maxlength='255' required
      )
      validation-errors(:subject='discussion', field='title')

      lmo-textarea(
        :model='discussion'
        field="description"
        :label="$t('discussion_form.context_label')"
        :placeholder="$t('discussion_form.context_placeholder')"
      )

      common-notify-fields(:model="discussion")
      //- p.discussion-form__visibility

      v-card-actions
        help-link(path='en/user_manual/threads/starting_threads')
        v-btn.discussion-form__edit-layout(v-if="discussion.id" @click="openEditLayout")
          span(v-t="'thread_arrangement_form.edit'")
        v-spacer
        v-btn.discussion-form__submit(
          color="primary"
          @click="submit()"
          :disabled="submitIsDisabled"
          :loading="discussion.processing"
        )
          span(v-if="!discussion.id" v-t="'discussion_form.start_thread'")
          span(v-if="discussion.id" v-t="'common.action.save'")
</template>
