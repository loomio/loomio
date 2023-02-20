<script lang="coffee">
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ChooseTemplate from '@/components/thread/choose_template'

export default
  components: {ChooseTemplate}
  data: ->
    discussion: null
    isDisabled: false
    groupId: null
    user: null

  mounted: ->
    @init()

  watch:
    '$route.query.group_id': 'init'
    '$route.query.blank_template': 'init'
    '$route.query.new_template': 'init'
    '$route.query.template_id': 'init'
    '$route.params.key': 'init'

  methods:
    init: ->
      @discussion = null

      if @$route.params.key
        Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
          @discussion = discussion.clone()
      else if discussionId = parseInt(@$route.query.template_id)
        Records.discussions.findOrFetchById(discussionId).then (discussion) =>
          @discussion = discussion.cloneTemplate()
          if discussion.groupId && AbilityService.canStartThread(discussion.group())
            @discussion.groupId = discussion.groupId
      else if @groupId = parseInt(@$route.query.group_id)
        if @$route.query.blank_template
          Records.groups.findOrFetchById(@groupId).then =>
            @discussion = Records.discussions.build
              title: @$route.query.title
              groupId: @groupId
        else if @$route.query.new_template
          Records.groups.findOrFetchById(@groupId).then =>
            @discussion = Records.discussions.build
              title: @$route.query.title
              groupId: @groupId
              template: true
        else
          # display templates for the group
          @discussion = null
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
  v-container.start-discussion-page.max-width-800.px-0.px-sm-3
    discussion-template-banner(v-if="discussion", :discussion="discussion")
    v-card
      discussion-form(
        v-if="discussion"
        :discussion='discussion'
        is-page
        :key="discussion.id"
        :user="user")

      div(v-if="!discussion && groupId")
        choose-template(:group-id="groupId")
   
</template>
