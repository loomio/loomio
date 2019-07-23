<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { submitDiscussion } from '@/shared/helpers/form'
import { map, sortBy, filter } from 'lodash'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import WatchRecords from '@/mixins/watch_records'
import UrlFor       from '@/mixins/url_for'

export default
  mixins: [AnnouncementModalMixin, WatchRecords, UrlFor]
  props:
    discussion: Object
    close: Function

  data: ->
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    availableGroups: []
    submitIsDisabled: false

  mounted: ->
    isNew = @discussion.isNew()
    @submit = submitDiscussion @, @discussion,
      successCallback: (data) =>
        discussionKey = data.discussions[0].key
        Records.discussions.findOrFetchById(discussionKey, {}, true).then (discussion) =>
          @close()
          if isNew
            @$router.push @urlFor(discussion)
            @openAnnouncementModal(Records.announcements.buildFromModel(discussion))


    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        # console.log "running query:", @discussion, Session.user().formalGroups()
        @availableGroups = filter(Session.user().formalGroups(), (group) -> AbilityService.canStartThread(group))

  methods:
    updatePrivacy: ->
      @discussion.private = @discussion.privateDefaultValue()

  computed:
    privacyTitle: ->
      if @discussion.private
        'common.privacy.private'
      else
        'common.privacy.public'

    privacyDescription: ->

      path = if @discussion.private == false
               'discussion_form.privacy_public'
             else if @discussion.group().parentMembersCanSeeDiscussions
               'discussion_form.privacy_organisation'
             else
               'discussion_form.privacy_private'
      @$t(path, {group:  @discussion.group().name, parent: @discussion.group().parentName()})

    groupSelectOptions: ->
      sortBy map(@availableGroups, (group) -> {
         text: group.fullName,
         value: group.id
      }), 'fullName'

    showGroupSelect: ->
      @discussion.isNew()

    maxThreads: ->
      return null unless @discussion.group()
      @discussion.group().parentOrSelf().subscriptionMaxThreads

    threadCount: ->
      return unless @discussion.group()
      @discussion.group().parentOrSelf().orgDiscussionsCount

    maxThreadsReached: ->
      @maxThreads && @threadCount >= @maxThreads

    subscriptionActive: ->
      return true unless @discussion.group()
      @discussion.group().parentOrSelf().subscriptionActive

    canStartThread: ->
      @subscriptionActive && !@maxThreadsReached

    showUpgradeMessage: ->
      @discussion.isNew() && !@canStartThread

</script>

<template lang="pug">
v-card.discussion-form
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline
      span(v-if="!discussion.isForking()")
        span(v-if="discussion.isNew()" v-t="'discussion_form.new_discussion_title'")
        span(v-if="!discussion.isNew()" v-t="'discussion_form.edit_discussion_title'")
      span(v-if="discussion.isForking()" v-t="'discussion_form.fork_discussion_title'")
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  .ma-4
    .lmo-hint-text(v-t="'group_page.discussions_placeholder'", v-show='discussion.isNew() && !discussion.isForking()')
    .lmo-hint-text(v-t="{ path: 'discussion_form.fork_notice', args: { count: discussion.forkedEvents.length, title: discussion.forkTarget().discussion().title } }", v-if='discussion.isForking()')

    div(v-show='showGroupSelect')
      label(for='discussion-group-field', v-t="'discussion_form.group_label'")
      v-select#discussion-group-field.discussion-form__group-select(v-model='discussion.groupId' :placeholder="$t('discussion_form.group_placeholder')" :items='groupSelectOptions' required='true' @change='discussion.fetchAndRestoreDraft(); updatePrivacy()')

    .body-1(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

    .discussion-form__group-selected(v-if='discussion.groupId && !showUpgradeMessage')
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input(:label="$t('discussion_form.title_label')" :placeholder="$t('discussion_form.title_placeholder')" v-model='discussion.title' maxlength='255')
      validation-errors(:subject='discussion', field='title')
      lmo-textarea(v-if="!discussion.isForking()" :model='discussion' field="description" :label="$t('discussion_form.context_label')" :placeholder="$t('discussion_form.context_placeholder')")
      v-list-item.discussion-form__privacy-notice
        v-list-item-avatar
          v-icon(v-if='discussion.private') mdi-lock-outline
          v-icon(v-if='!discussion.private') mdi-earth
        v-list-item-content
          v-list-item-title.discussion-privacy-icon__title(v-t="privacyTitle")
          v-list-item-subtitle.discussion-privacy-icon__subtitle(v-html='privacyDescription')
  v-card-actions.discussion-form-actions
    v-spacer
    v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled || !discussion.groupId" v-t="'common.action.start'" v-if="discussion.isNew()")
    v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-t="'common.action.save'" v-if="!discussion.isNew()")
</template>
