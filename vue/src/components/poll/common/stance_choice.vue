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
    },
    verbose: {
      type: Boolean,
      default: false
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

<template lang="pug">
span.poll-common-stance-choice.text-truncate(:class="'poll-common-stance-choice--' + pollType")
  span(v-if='poll.config().has_option_icon')
    v-avatar(tile :size="size")
      img(:style="{width: size + 'px', height: size + 'px'}" :src="'/img/' + pollOption.icon + '.svg'" :alt='optionName')
    span.ml-2(v-if="verbose") {{ optionName }}
  v-chip(v-if='poll.pollOptionNameFormat == "iso8601"' :color="colorFor(stanceChoice.score)")
    poll-meeting-time(:name="optionName")
  span(v-if='!poll.config().has_option_icon && poll.pollOptionNameFormat != "iso8601"')
    //common-icon.mr-2(size="small" :color="pollOption.color" name="mdi-check-circle")
    span {{ optionName }}
</template>
