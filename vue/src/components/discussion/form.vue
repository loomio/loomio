<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { discussionPrivacy } from '@/shared/helpers/helptext'
import { submitDiscussion } from '@/shared/helpers/form'
import { map, sortBy, filter } from 'lodash'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [AnnouncementModalMixin, WatchRecords]
  props:
    discussion: Object
    close: Function

  data: ->
    isDisabled: false
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    availableGroups: []
    submitIsDisabled: false

  mounted: ->
    @submit = submitDiscussion @, @discussion,
      successCallback: (data) =>
        discussionKey = data.discussions[0].key
        Records.discussions.findOrFetchById(discussionKey, {}, true).then (discussion) =>
          @close()
          @$router.push("/d/#{discussionKey}")
          @openAnnouncementModal(Records.announcements.buildFromModel(discussion))


    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        console.log "running query:", @discussion, Session.user().formalGroups()
        @availableGroups = filter(Session.user().formalGroups(), (group) -> AbilityService.canStartThread(group))

  methods:
    updatePrivacy: ->
      @discussion.private = @discussion.privateDefaultValue()

  computed:
    showPrivacyForm: ->
      return unless @discussion.group()
      @discussion.group().discussionPrivacyOptions == 'public_or_private'

    privacyPrivateDescription: ->
      @$t discussionPrivacy(discussion, true),
        group:  @discussion.group().name,
        parent: @discussion.group().parentName()

    groupSelectOptions: ->
      console.log "uppdating group select options", @availableGroups
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
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      v-flex
        .headline(v-if="!discussion.isForking()" v-t="'discussion_form.new_discussion_title'")
        .headline(v-if="discussion.isForking()" v-t="'discussion_form.fork_discussion_title'")
      v-flex(shrink)
        dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    .lmo-hint-text(v-t="'group_page.discussions_placeholder'", v-show='discussion.isNew() && !discussion.isForking()')
    .lmo-hint-text(v-t="{ path: 'discussion_form.fork_notice', args: { count: discussion.forkedEvents.length, title: discussion.forkTarget().discussion().title } }", v-if='discussion.isForking()')
    .md-block(v-show='showGroupSelect')
      label(for='discussion-group-field', v-t="'discussion_form.group_label'")
      v-select#discussion-group-field.discussion-form__group-select(v-model='discussion.groupId' :placeholder="$t('discussion_form.group_placeholder')" :items='groupSelectOptions' required='true' @change='discussion.fetchAndRestoreDraft(); updatePrivacy()')
      .md-errors-spacer

    .md-body-1(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

    .discussion-form__group-selected(v-if='discussion.groupId && !showUpgradeMessage')
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input(:label="$t('discussion_form.title_label')", :placeholder="$t('discussion_form.title_placeholder')", v-model='discussion.title', maxlength='255')
      validation-errors(:subject='discussion', field='title')
      lmo-textarea(v-if="!discussion.isForking()" :model='discussion' field="description" :placeholder="'discussion_form.context_placeholder'")
      v-list.discussion-form__options
        v-list-tile.discussion-form__privacy-form(v-if='showPrivacyForm')
          v-radio-group(v-model='discussion.private')
            v-radio.md-checkbox--with-summary.discussion-form__public(:value='false')
              discussion-privacy-icon(slot='label', :discussion='discussion', :private='false')
            v-radio.md-checkbox--with-summary.discussion-form__private(:value='true')
              discussion-privacy-icon(slot='label', :discussion='discussion', :private='true')
        v-list-tile.discussion-form__privacy-notice(v-if='!showPrivacyForm')
          label.discussion-form__privacy-notice.lmo-flex(layout='row')
            i.mdi.mdi-24px.mdi-lock-outline.lmo-margin-right(v-if='discussion.private')
            i.mdi.mdi-24px.mdi-earth.lmo-margin-right(v-if='!discussion.private')
            discussion-privacy-icon(:discussion='discussion')
  v-card-actions
    .discussion-form-actions.lmo-md-actions
      v-btn.discussion-form__submit(@click="submit()" :disabled="submitIsDisabled || !discussion.groupId" v-t="'common.action.start'" v-if="discussion.isNew()" class="md-primary md-raised discussion-form__submit")
      v-btn.discussion-form__submit(@click="submit()" :disabled="submitIsDisabled" v-t="'common.action.save'" v-if="!discussion.isNew()" class="md-primary md-raised discussion-form__submit")
</template>
