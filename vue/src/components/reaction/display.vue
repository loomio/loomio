<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import {merge, capitalize, difference, keys, throttle, startsWith, each, compact} from 'lodash'
import WatchRecords from '@/mixins/watch_records'
import { colonToUnicode, stripColons, imgForEmoji, srcForEmoji, replaceEmojis } from '@/shared/helpers/emojis'

export default
  mixins: [WatchRecords]
  props:
    model: Object
    fetch:
      type: Boolean
      default: false

  data: ->
    diameter: 20
    maxNamesCount: 10
    reactionHash: {all: []}
    replaceEmojis: replaceEmojis

  mounted: ->
    @watchRecords
      collections: ['reactions']
      query: (store) =>
        @reactionHash = {all: []}
        each Records.reactions.find(@reactionParams), (reaction) =>
          unless @reactionHash[reaction.reaction]?
            @reactionHash[reaction.reaction] = []
          user = Records.users.find(reaction.userId)
          @reactionHash[reaction.reaction].push(user)
          @reactionHash['all'].push(user)
          true

    if @fetch
      Records.reactions.fetch
        params:
          reactable_type: capitalize(@model.constructor.singular)
          reactable_id: @model.id


  computed:
    reactionParams: ->
      reactableType: capitalize(@model.constructor.singular)
      reactableId: @model.id

    reactionTypes: ->
      compact difference keys(@reactionHash), ['all']

    myReaction: ->
      return unless Session.isSignedIn()
      Records.reactions.find(merge({}, @reactionParams, userId: Session.user().id))[0]

    otherReaction: ->
      Records.reactions.find(merge({}, @reactionParams, {userId: {'$ne': Session.user().id}}))[0]

    reactionTypes: ->
      difference keys(@reactionHash), ['all']

  methods:
    srcForEmoji: srcForEmoji
    stripColons: stripColons
    colonToUnicode: colonToUnicode
    removeMine: (reaction) ->
      mine = Records.reactions.find(merge({}, @reactionParams,
        userId:   Session.user().id
        reaction: reaction
      ))[0]
      mine.destroy() if mine

    translate: (shortname) ->
      title = emojiTitle(shortname)
      if startsWith(title, "reactions.") then shortname else title

    countFor: (reaction) ->
      if @reactionHash[reaction]?
        @reactionHash[reaction].length - @maxNamesCount
      else
        0

</script>
<template lang="pug">
.reactions-display.mr-2(v-if="reactionTypes.length")
  .reactions-display__emojis
    .reaction.lmo-pointer(@click="removeMine(reaction)" v-for="reaction in reactionTypes" :key="reaction")
      v-tooltip(bottom)
        template(v-slot:activator="{ on }")
          .reactions-display__group(v-on="on")
            span(v-if="replaceEmojis()") {{colonToUnicode(reaction)}}
            img.emoji(v-else :src="srcForEmoji(colonToUnicode(reaction))")
            user-avatar.reactions-display__author(v-for="user in reactionHash[reaction]" :key="user.id" :user="user" :size="diameter")
        .reactions-display__name(v-for="user in reactionHash[reaction]" :key="user.id")
          span {{ user.name }}
</template>

<style lang="sass">
.reactions-display__group
	opacity: 0.8
	display: flex
	align-items: center
	margin-right: 2px
	span
		font-size: 20px
		line-height: 20px
		margin-bottom: -5px
.reactions-display__emojis
	display: flex
</style>
