<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import ReactionService from '@/shared/services/reaction_service';
import { merge, capitalize, difference, keys, startsWith, each, compact } from 'lodash-es';
import { colonToUnicode, stripColons, srcForEmoji, emojiSupported } from '@/shared/helpers/emojis';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],

  props: {
    model: Object,
    canEdit: Boolean,
    size: {
      type: String,
      default: 'default'
    },
    color: String,
    variant: String
  },

  data() {
    return {
      userId: Session.user().id,
      diameter: (this.size == 'x-small' && 20) || 24,
      maxNamesCount: 10,
      reactions: [],
      reactionHash: {all: []},
      emojiSupported
    };
  },

  created() {
    ReactionService.enqueueFetch(this.model);
  },

  mounted() {
    this.watchRecords({
      collections: ['reactions'],
      query: this.runQuery
    });
  },

  computed: {
    reactionParams() {
      return {
        reactableType: capitalize(this.model.constructor.singular),
        reactableId: this.model.id
      };
    },

    reactionTypes() {
      return difference(keys(this.reactionHash), ['all']);
    }
  },

  methods: {
    srcForEmoji,
    stripColons,
    colonToUnicode,
    runQuery() {
      this.reactionHash = {all: []};
      this.reactions = []
      each(Records.reactions.find(this.reactionParams), reaction => {
        this.reactions.push(reaction);
        let user;
        if (this.reactionHash[reaction.reaction] == null) {
          this.reactionHash[reaction.reaction] = [];
        }
        if (user = Records.users.find(reaction.userId)) {
          this.reactionHash[reaction.reaction].push(user);
          this.reactionHash['all'].push(user);
        }
        return true;
      });
    },
    removeMine(reaction) {
      if (!this.canEdit) { return; }
      const mine = Records.reactions.find(merge({}, this.reactionParams, {
        userId:   Session.user().id,
        reaction
      }
      ))[0];
      if (mine) { mine.destroy(); }
      this.runQuery();
    },

    translate(shortname) {
      const title = emojiTitle(shortname);
      if (startsWith(title, "reactions.")) { return shortname; } else { return title; }
    },

    countFor(reaction) {
      if (this.reactionHash[reaction] != null) {
        return this.reactionHash[reaction].length - this.maxNamesCount;
      } else {
        return 0;
      }
    }
  }
};

</script>
<template lang="pug">
.reactions-display.mr-1(v-if="reactionTypes.length")
  v-btn(:color="color" variant="text" density="comfortable")
    .reaction.lmo-pointer(v-for="reaction in reactionTypes" :key="reaction")
      .reactions-display__emojis
      //.reaction.lmo-pointer(@click="removeMine(reaction, canEdit)" v-for="reaction in reactionTypes" :key="reaction")
      .reactions-display__group
        span(:class="(size == 'x-small' && 'small') || undefined") {{colonToUnicode(reaction)}}
        template(v-if="reactionHash[reaction].length > 2")
          span.reactions-display__count {{reactionHash[reaction].length}}
        template(v-else)
          user-avatar.reactions-display__author(no-link v-for="user in reactionHash[reaction]" :key="user.id" :user="user" :size="diameter")
    v-menu(activator="parent")
      v-list
        template(v-for="reaction in reactions" :key="reaction.id")
          v-list-item(v-if="reaction.userId == userId && canEdit" density="compact" :title="reaction.user().name" )
            template(v-slot:prepend)
              span.reaction--char.mr-2 {{colonToUnicode(reaction.reaction)}}
              user-avatar.mr-2(:user="reaction.user()")
            template(v-slot:append)
              v-btn(icon variant="text" size="small" density="comfortable" @click="removeMine(reaction.reaction)")
                common-icon(name="mdi-close")
          v-list-item(v-else density="compact" :title="reaction.user().name" )
            template(v-slot:prepend)
              span.reaction--char.mr-2 {{colonToUnicode(reaction.reaction)}}
              user-avatar.mr-2(:user="reaction.user()")






</template>

<style lang="sass">
.reactions-display__count
  font-weight: 600
  font-size: inherit !important

.reaction--char
  font-size: 22px
  line-height: 20px

.reactions-display__group
  overflow: hidden
  opacity: 0.8
  display: flex
  align-items: center
  margin-right: 2px
  span
    font-size: 22px
    line-height: 20px
  span.small
    font-size: 20px
    line-height: 18px

  .user-avatar
    span
      font-size: 10px
      line-height: 20px
      margin-bottom: -2px
.reactions-display__emojis
  display: flex
</style>
