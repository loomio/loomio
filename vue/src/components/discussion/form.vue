<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { map, sortBy, filter, debounce, without } from 'lodash'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

export default
  props:
    discussion: Object
    close: Function
    isPage: Boolean

  data: ->
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    availableGroups: []
    submitIsDisabled: false
    searchResults: []
    query: ''

  mounted: ->
    Records.memberships.fetchByGroup(@discussion.groupId, per: 100)

    @search = debounce ->
      return unless @query && @query.length > 2
      Records.users.fetchMentionable(@query, @discussion.group())

    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        groups = [@discussion.group().parentOrSelf()].concat(@discussion.group().subgroups())
        @availableGroups = filter(groups, (group) -> AbilityService.canStartThread(group))
        @updateSearchResults()

  methods:
    remove: (item) ->
      @discussion.recipientIds = without(@discussion.recipientIds, item.id)

    updateSearchResults: ->
      memberIds = without(@discussion.group().memberIds(), Session.user().id)
      chain = Records.users.collection.chain().find(id: {$in: memberIds})
      if @query
        chain = chain.find(
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}},
            {username: {'$regex': ["^#{@query}", "i"]}},
            {name: {'$regex': [" #{@query}", "i"]}}
          ]
        )
      @searchResults = chain.simplesort('name').data()

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

  watch:
    'discussion.visibleTo': (val) ->
      if val == 'discussion'
        @discussion.groupId = @discussion.group().parentOrSelf().id

    query: (q) ->
      @search(q)
      @updateSearchResults()

  computed:
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


    # privacyTitle: ->
    #   if @discussion.private
    #     'common.privacy.private'
    #   else
    #     'common.privacy.public'
    #
    # privacyDescription: ->
    #
    #   path = if @discussion.private == false
    #            'discussion_form.privacy_public'
    #          else if @discussion.group().parentMembersCanSeeDiscussions
    #            'discussion_form.privacy_organisation'
    #          else
    #            'discussion_form.privacy_private'
    #   @$t(path, {group:  @discussion.group().name, parent: @discussion.group().parentName()})

    groupSelectOptions: ->
      map(@availableGroups, (group) -> {
         text: group.name,
         value: group.id
      })

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
    .body-1(v-if="showUpgradeMessage")
      p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
      p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

    .discussion-form__group-selected(v-if='discussion.groupId && discussion.group() && !showUpgradeMessage')
      p {{discussion.group().fullName}}
      v-select(v-model="discussion.visibleTo" :items="visibleTos" :label="$t('common.privacy.privacy')")
      v-select(v-if="discussion.visibleTo == 'group'" v-model="discussion.groupId" :items="groupSelectOptions" :label="$t('discussion_form.group_label')" :placeholder="$t('discussion_form.group_placeholder')")
      v-autocomplete(v-if="discussion.visibleTo == 'discussion'" multiple chips hide-no-data hide-selected no-filter v-model='discussion.recipientIds' @change="query= ''" :search-input.sync="query" item-text='name' item-value="id" item-avatar="avatar_url.large" :label="$t('discussion_form.invite')" :items='searchResults')
        template(v-slot:selection='data')
          v-chip.chip--select-multi(:value='data.selected', close, @click:close='remove(data.item)')
            user-avatar.mr-1(:user="data.item" size="small" :no-link="true")
            span {{ data.item.name }}
        template(v-slot:item='data')
          v-list-item-avatar
            user-avatar(:user="data.item" size="small" :no-link="true")
          v-list-item-content.announcement-chip__content
            v-list-item-title(v-html='data.item.name')
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input.text-h5(:label="$t('discussion_form.title_label')" :placeholder="$t('discussion_form.title_placeholder')" v-model='discussion.title' maxlength='255')
      validation-errors(:subject='discussion', field='title')
      lmo-textarea(:model='discussion' field="description" :label="$t('discussion_form.context_label')" :placeholder="$t('discussion_form.context_placeholder')")
        template(v-slot:actions)
          v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled || !discussion.groupId" v-t="'discussion_form.start_thread'" v-if="discussion.isNew()")
          v-btn.discussion-form__submit(color="primary" @click="submit()" :disabled="submitIsDisabled" v-t="'common.action.save'" v-if="!discussion.isNew()")
</template>
