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

      else if templateId = parseInt(@$route.query.template_id)
        Records.discussionTemplates.findOrFetchById(templateId).then (template) =>
          @discussion = template.buildDiscussion()
          if template.groupId && AbilityService.canStartThread(template.group())
            @discussion.groupId = template.groupId

      else if templateKey = @$route.query.template_key
        Records.discussionTemplates.findOrFetchByKey(@$route.query.template_key, @$route.query.group_id).then (template) =>
          @discussion = template.buildDiscussion()
          console.log 'template.groupId', template.groupId
          if template.groupId && AbilityService.canStartThread(template.group())
            @discussion.groupId = template.groupId

      else if @groupId = parseInt(@$route.query.group_id)
        Records.groups.findOrFetchById(@groupId).then =>
          @discussion = Records.discussions.build
            title: @$route.query.title
            groupId: @groupId
            descriptionFormat: Session.defaultFormat()

      else if userId = parseInt(@$route.query.user_id)
        Records.users.findOrFetchById(userId).then (user) =>
          @user = user
          @discussion = Records.discussions.build
            title: @$route.query.title
            groupId: null
            descriptionFormat: Session.defaultFormat()

      else
        @discussion = Records.discussions.build
          title: @$route.query.title
          descriptionFormat: Session.defaultFormat()

</script>
<template lang="pug">
v-main
  v-container.start-discussion-page.max-width-800.px-0.px-sm-3
    v-card
      discussion-form(
        v-if="discussion"
        :discussion='discussion'
        is-page
        :key="discussion.id"
        :user="user")
</template>
