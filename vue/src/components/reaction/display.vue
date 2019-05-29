<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import { Emoji } from 'emoji-mart-vue'
import {merge, capitalize, difference, keys, throttle, startsWith, each} from 'lodash'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [WatchRecords]
  props:
    model: Object
    load: Boolean

  components:
    Emoji: Emoji

  data: ->
    diameter: 20
    maxNamesCount: 10
    loaded: !@load
    reactionHash: {all: []}

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

    if @load
      Records.reactions.fetch(params:
        reactable_type: capitalize(@model.constructor.singular)
        reactable_id: @model.id
      ).finally => @loaded = true


  computed:
    reactionParams: ->
      reactableType: capitalize(@model.constructor.singular)
      reactableId: @model.id

    reactionTypes: ->
      difference keys(@reactionHash), ['all']

    myReaction: ->
      return unless Session.isSignedIn()
      Records.reactions.find(merge({}, @reactionParams, userId: Session.user().id))[0]

    otherReaction: ->
      Records.reactions.find(merge({}, @reactionParams, {userId: {'$ne': Session.user().id}}))[0]

    reactionTypes: ->
      difference keys(@reactionHash), ['all']

  methods:
    smileCorrect: (shortcode) ->
      corrections =
        ':slight_smile:': ':smile:'
        ':thinking:': 'thinking_face'
        ':fingers_crossed:': ':crossed_fingers:'
        ':nerd:': ':nerd_face:'

      if corrections[shortcode]?
        corrections[shortcode]
      else
        shortcode

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
.reactions-display.lmo-flex.lmo-flex__center
  loading(v-if="!loaded" :diameter="diameter")
  .lmo-flex.lmo-flex__center(v-if="loaded")
    .reactions-display__emojis
      .reaction.lmo-pointer(v-if="loaded" @click="removeMine(reaction)" v-for="reaction in reactionTypes")
        v-tooltip(bottom)
          template(v-slot:activator="{ on }")
            .fake-chip(v-on="on")
              //- span {{reaction}}
              emoji(:emoji="smileCorrect(reaction)" :size="diameter")
              //- span(v-if="reactionHash[reaction].length > 1") {{reactionHash[reaction].length}}
              user-avatar.reactions-display__author(v-for="user in reactionHash[reaction]" :key="user.id" :user="user" size="tiny")

          .reactions-display__name(v-for="user in reactionHash[reaction]" :key="user.id")
            span {{ user.name }}
    //- .reactions-display__names(v-if="myReaction")
    //-   span(v-if="reactionHash.all.length == 1" v-t="'reactions_display.you'")
    //-   span(v-if="reactionHash.all.length == 2" v-t="{path: 'reactions_display.you_and_name', args: {name: otherReaction.user().name}}")
    //-   span(v-if="reactionHash.all.length > 2"  v-t="{path: 'reactions_display.you_and_name_and_count_more', args: {name: otherReaction.user().name, count: reactionHash.all.length - 2}}")
    //- .reactions-display__names(v-if="!myReaction")
    //-   span(v-if="reactionHash.all.length == 1") {{reactionHash.all[0]}}
    //-   span(v-if="reactionHash.all.length > 1" v-t="{path: 'reactions_display.name_and_count_more', args: {name: reactionHash.all[0], count: reactionHash.all.length - 1}}")
</template>

<style lang="scss">
.fake-chip {
  display: flex;
  align-items: center;
  margin-right: 2px;
}
.reactions-display__emojis {
  display: flex;
}
</style>
