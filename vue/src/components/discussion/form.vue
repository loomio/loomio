<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { map, sortBy, filter, debounce, without, uniq, find } from 'lodash'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import RecipientsAutocompleteMixin from '@/mixins/recipients_autocomplete_mixin'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  mixins: [RecipientsAutocompleteMixin]

  props:
    discussion: Object
    close: Function
    isPage: Boolean

  data: ->
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    submitIsDisabled: false
    searchResults: []
    subscription: @discussion.group().parentOrSelf().subscription
    groupItems: []
    initialRecipients: []

  mounted: ->
    Records.users.fetchGroups()
    @fetchMemberships()

    @watchRecords
      collections: ['groups', 'memberships']
      query: (records) =>
        @updateSuggestions()
        @updateGroupItems()

  watch:
    'discussion.groupId':
      immediate: true
      handler: (groupId) ->
        @fetchMemberships()
        @updateSuggestions()
        @subscription = @discussion.group().parentOrSelf().subscription
        @initialRecipients = (!@discussion.id && @audiences.length && [@audiences[0]]) || []
        @newRecipients(@initialRecipients)
        @reset = !@reset

  methods:
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
      @groupItems = [{text: @$t('discussion_form.none_invite_only'), value: null}].concat Session.user().groups().map (g) -> {text: g.fullName, value: g.id}

    updatePrivacy: ->
      @discussion.private = @discussion.privateDefaultValue()

    newRecipients: (val) ->
      @recipients = val
      @discussion.recipientAudience = (find(val, (o) -> o.type == 'audience') || {}).id
      @discussion.recipientUserIds = map filter(val, (o) -> o.type == 'user'), 'id'
      @discussion.recipientEmails = map filter(val, (o) -> o.type == 'email'), 'name'

  computed:
    audiences: ->
      ret = []
      canAnnounce = !!(@model.group().adminsInclude(Session.user()) || @model.group().membersCanAnnounce)
      if @recipients.length == 0
        if @model.groupId && canAnnounce
          ret.push
            id: 'group'
            name: @model.group().name
            size: @model.group().acceptedMembershipsCount
            icon: 'mdi-account-group'
        if @model.membersCount > 1
          ret.push
            id: 'discussion_group'
            name: @$t('announcement.audiences.discussion_group')
            size: @model.membersCount
            icon: 'mdi-forum'

      ret.filter (a) =>
        (@query && a.name.match(new RegExp(@query, 'i'))) || true

    model: -> @discussion

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
    h1.headline
      span(v-if="isMovingItems" v-t="'discussion_form.moving_items_title'")
      template(v-else)
        span(v-if="!discussion.id" v-t="'discussion_form.new_discussion_title'")
        span(v-if="discussion.id" v-t="'discussion_form.edit_discussion_title'")
    v-spacer
    dismiss-modal-button(v-if="!isPage" aria-hidden='true' :close='close')
    v-btn(v-if="isPage && discussion.id" icon  aria-hidden='true' :to="urlFor(discussion)")
      v-icon mdi-close
  .pa-4
    v-select(v-if="!discussion.id" v-model="discussion.groupId" :items="groupItems" :label="$t('common.group')")
    //- p discussion.recipientAudience {{discussion.recipientAudience}}
    //- p initialRecipients {{initialRecipients}}
    //- p recipients {{recipients}}
    //- p audiences {{audiences}}
    recipients-autocomplete(
      v-if="!discussion.id"
      :label="$t(discussion.id ? 'action_dock.notify' : 'common.action.invite')"
      :placeholder="$t('announcement.form.discussion_'+ (discussion.id ? 'edited' : 'announced')+ '.helptext')"
      :users="users"
      :initial-recipients="initialRecipients"
      :audiences="audiences"
      :reset="reset"
      @new-query="newQuery"
      @new-recipients="newRecipients")

    div(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

    .discussion-form__group-selected(v-if='!showUpgradeMessage')
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input.text-h5(:label="$t('discussion_form.title_label')" :placeholder="$t('discussion_form.title_placeholder')" v-model='discussion.title' maxlength='255' required)
      validation-errors(:subject='discussion', field='title')
      lmo-textarea(:model='discussion' field="description" :label="$t('discussion_form.context_label')" :placeholder="$t('discussion_form.context_placeholder')")
      //- v-checkbox(:label="$t('discussion_form.notify_group')" v-model="discussion.notifyGroup" :disabled="!canAnnounce")
      //- .caption.discussion-form__number-notified(v-if="notificationsCount != 1" v-t="{ path: 'poll_common_notify_group.members_count', args: { count: notificationsCount } }")
      //- .caption.discussion-form__number-notified(v-else v-t="'discussion_form.one_person_notified'")

      common-notify-fields(:model="discussion")
      //- v-text-field(
      //-   v-if="discussion.id"
      //-   :label="$t('discussion_form.change_log_label')"
      //-   :placeholder="$t('discussion_form.change_log_placeholder')"
      //-   v-model="discussion.recipientMessage"
      //-   counter="140")
      //-
      //- recipients-autocomplete(
      //-   v-if="discussion.id"
      //-   :label="$t(discussion.id ? 'action_dock.notify' : 'common.action.invite')"
      //-   :placeholder="$t('announcement.form.discussion_'+ (discussion.id ? 'edited' : 'announced')+ '.helptext')"
      //-   :users="users"
      //-   :initial-recipients="initialRecipients"
      //-   :audiences="audiences"
      //-   :reset="reset"
      //-   @new-query="newQuery"
      //-   @new-recipients="newRecipients")
      //-

      v-card-actions
        v-spacer
        v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-t="'discussion_form.start_thread'" v-if="!discussion.id")
        v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-t="'common.action.save'" v-if="discussion.id")
</template>
