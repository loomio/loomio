<script lang="js">
import { capitalize } from 'lodash-es';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';

export default {
  props: {
    model: Object,
    variant: String,
    color: String,
    size: {
      type: String,
      default: 'default'
    }
  },

  data() {
    return {
      search: null,
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
    }
  }
};

</script>

<template lang="pug">
v-menu.reactions-input(:close-on-content-click="true")
  template(v-slot:activator="{ props }")
    v-btn.mr-1.emoji-picker__toggle.action-button(icon :size="size" density="comfortable" v-bind="props" :color="color" :variant="variant")
      common-icon(:size="size" name="mdi-emoticon-happy-outline" :color="color")
  emoji-picker(:insert="insert" :is-poll="model.isA('poll') || model.isA('stance') || model.isA('outcome')")
</template>

<style lang="sass">
.reactions-input
	display: flex
	align-items: center

</style>
