<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Session   from '@/shared/services/session'

export default
  data: ->
    group: AppConfig.currentGroup
    userName: Session.user().name
  methods:
    timestamp: -> moment().format('h:ma')
</script>
<template lang="pug">
.install-slack-invite-preview.lmo-flex(layout='row')
  .install-slack-invite-preview__avatar
    v-img(src='https://s3-us-west-2.amazonaws.com/slack-files2/bot_icons/2017-03-29/161925077303_48.png')
  .install-slack-invite-preview__content
    .install-slack-invite-preview__title
      strong.install-slack-invite-preview__loomio-bot Loomio Bot
      span.install-slack-invite-preview__app APP
      span.install-slack-invite-preview__title-timestamp {{ timestamp() }}
    .install-slack-invite-preview__published
    .install-slack-invite-preview__message(v-t="{ path: 'install_slack.invite.group_published_preview', args { author: userName, name: group.name } }")
    .install-slack-invite-preview__attachment
      .install-slack-invite-preview__bar
      .install-slack-invite-preview__poll
        .install-slack-invite-preview__author {{ userName }}
        .install-slack-invite-preview__poll-title {{ group.name }}
        .install-slack-invite-preview__poll-details(v-if='poll.details') {{ group.description }}
        .install-slack-invite-preview__view-it(v-t="'poll_common_publish_slack_preview.view_it_on_loomio'")
        .install-slack-invite-preview__timestamp(v-t="{ path: 'poll_common_publish_slack_preview.timestamp', args: { timestamp: timestamp() } }")
</template>
