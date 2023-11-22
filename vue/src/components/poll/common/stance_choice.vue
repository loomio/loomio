<script lang="js">
import AppConfig from '@/shared/services/app_config';

export default
{
  props: {
    poll: {
      type: Object,
      required: true
    },
    stanceChoice: {
      type: Object,
      required: true
    },
    size: {
      type: Number,
      default: 24
    }
  },

  computed: {
    color() {
      return this.pollOption.color;
    },

    pollOption() {
      return this.stanceChoice.pollOption;
    },

    pollType() {
      return this.poll.pollType;
    },

    optionName() {
      if (AppConfig.pollTypes[this.poll.pollType].poll_option_name_format === 'i18n') {
        return this.$t('poll_' + this.pollType + '_options.' + this.stanceChoice.pollOption.name);
      } else {
        return this.stanceChoice.pollOption.name;
      }
    }
  },

  methods: {
    emitClick() { this.$emit('click'); },

    colorFor(score) {
      switch (score) {
        case 2: return AppConfig.pollColors.proposal[0];
        case 1: return AppConfig.pollColors.proposal[1];
        case 0: return AppConfig.pollColors.proposal[2];
      }
    }
  }
};

</script>

<template>
<span class="poll-common-stance-choice text-truncate" :class="'poll-common-stance-choice--' + pollType" row="row">
  <v-avatar tile="tile" :size="size" v-if="poll.config().has_option_icon"><img :src="'/img/' + pollOption.icon + '.svg'" :alt="optionName"/></v-avatar>
  <v-chip v-if="poll.pollOptionNameFormat == 'iso8601'" outlined="outlined" :color="colorFor(stanceChoice.score)" @click="emitClick">
    <poll-meeting-time :name="optionName"></poll-meeting-time>
  </v-chip><span v-if="!poll.config().has_option_icon && poll.pollOptionNameFormat != 'iso8601'">
    <common-icon class="mr-2" small="small" :color="pollOption.color" name="mdi-check-circle"></common-icon><span>{{ optionName }}</span></span></span>
</template>
