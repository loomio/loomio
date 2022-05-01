<script lang="coffee">
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'

export default
  data: ->
    discussion: null
    isDisabled: false
    group: null
    user: null
    templates: []

  mounted: ->
    @init()
    if groupId = parseInt(@$route.query.group_id)
      @watchRecords
        key: "newDiscussionInGroup#{groupId}"
        collections: ['discussions']
        query: =>
          @templates = Records.discussions.collection.chain().find(
            groupId: groupId,
            template: true).data()

  watch:
    '$route.query.group_id': 'init'
    '$route.query.no_template': 'init'
    '$route.query.template_discussion_id': 'init'
    '$route.params.key': 'init'

  methods:
    init: ->
      @discussion = null
      titleKey = if @$route.params.key
        'discussion_form.edit_discussion_title'
      else
        'discussion_form.new_discussion_title'

      EventBus.$emit 'currentComponent', { page: 'startDiscussionPage', titleKey: titleKey}

      if Session.isSignedIn()
        # editing existing discussion by query.key
        if @$route.params.key
          Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
            @discussion = discussion.clone()

        # new discussion from template discussion_id
        else if discussionId = parseInt(@$route.query.template_discussion_id)
          Records.discussions.findOrFetchById(discussionId).then (discussion) =>
            @discussion = discussion.cloneTemplate()
            if discussion.groupId && AbilityService.canStartThread(discussion.group())
              @discussion.groupId = discussion.groupId

        # new discussion in a group
        else if groupId = parseInt(@$route.query.group_id)
          if @$route.query.no_template
            Records.groups.findOrFetchById(groupId).then =>
              @discussion = Records.discussions.build
                title: @$route.query.title
                groupId: groupId
          else
            Records.discussions.fetch
              params:
                group_id: groupId
                filter: 'templates'
                exclude_types: 'user poll'
                per: 50

        else if userId = parseInt(@$route.query.user_id)
          Records.users.findOrFetchById(userId).then (user) =>
            @user = user
            @discussion = Records.discussions.build
              title: @$route.query.title
              groupId: null

        else
          @discussion = Records.discussions.build
            title: @$route.query.title

</script>
<template lang="pug">
v-main
  v-container.start-discussion-page.max-width-800
    discussion-template-banner(v-if="discussion" :discussion="discussion")
    v-card
      discussion-form(
        v-if="discussion"
        :discussion='discussion'
        is-page
        :key="discussion.id"
        :user="user")

      div(v-if="!discussion && $route.query.group_id && !$route.query.no_template")
        v-card-title
          h1.headline(tabindex="-1") Start thread from template
        v-list
          v-list-item(
            :to="'/d/new?no_template=1&group_id='+$route.query.group_id"
          )
            v-list-item-content
              v-list-item-title Blank
          v-list-item(
            v-for="template in templates" 
            :key="template.id"
            :to="'/d/new?template_discussion_id='+template.id"
          )
            v-list-item-content
              v-list-item-title {{template.title}}
 
</template>
