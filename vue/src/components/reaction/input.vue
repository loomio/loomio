<script lang="js">
import { capitalize } from 'lodash-es';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';

export default {
  props: {
    model: Object,
    small: Boolean
  },

  data() {
    return {
      search: null,
      closeEmojiMenu: false
    };
  },

  methods: {
    insert(emoji) {
      const params = {
        reactableType: capitalize(this.model.constructor.singular),
        reactableId: this.model.id,
        userId: Session.user().id
      };

      const reaction = Records.reactions.find(params)[0] || Records.reactions.build(params);
      reaction.reaction = `:${emoji}:`;
      reaction.save();
      this.closeEmojiMenu = true;
    }
  }
};

</script>

<template lang="pug">
v-menu.reactions-input(:close-on-content-click="true" v-model="closeEmojiMenu")
  template(v-slot:activator="{on, attrs}")
    v-btn.emoji-picker__toggle.action-button(icon :small="small" v-on="on" v-bind="attrs" )
      v-icon(:small="small") mdi-emoticon-outline
  emoji-picker(:insert="insert" :is-poll="model.isA('poll') || model.isA('stance') || model.isA('outcome')")
</template>

<style lang="sass">
.reactions-input
	display: flex
	align-items: center

</style>
