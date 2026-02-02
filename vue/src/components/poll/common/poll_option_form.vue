<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import { I18n } from '@/i18n';

export default {
  props: {
    pollOption: Object,
    poll: Object,
    submitFn: Function,
    edit: Boolean
  },

  data() {
    return {
      testEnabled: !!this.pollOption.testOperator,
      nameRules: [v => (v.length <= 60) || I18n.global.t("poll_option_form.option_name_validation")],
      icons: [
        {title: I18n.global.t('poll_proposal_options.agree'), value: 'agree'},
        {title: I18n.global.t('poll_proposal_options.disagree'), value: 'disagree'},
        {title: I18n.global.t('poll_proposal_options.abstain'), value: 'abstain'},
        {title: I18n.global.t('poll_proposal_options.block'), value: 'block'}
      ]
    };
  },

  computed: {
    hasOptionIcon() { return this.poll.config().has_option_icon; },
    hasOptionPrompt() { return this.poll.config().per_option_reason_prompt; },
    hasOptionMeaning() { return this.poll.config().options_have_meaning; },
    cardTitle() { return this.edit ? 'poll_option_form.edit_option' : 'poll_poll_form.add_option_placeholder' }
  },

  methods: {
    submit() {
      if (!this.testEnabled) {
        this.pollOption.testOperator = null;
        this.pollOption.testPercent = null;
        this.pollOption.testAgainst = null;
      }
      this.submitFn(this.pollOption);
      EventBus.$emit('closeModal');
    }
  },
  mounted() {
    this.pollOption.testOperator = this.pollOption.testOperator || 'gte';
    this.pollOption.testPercent = this.pollOption.testPercent || 50;
    this.pollOption.testAgainst = this.pollOption.testAgainst || 'score_percent';
  },

  watch: {
    'pollOption.icon'(val) {
      if (!this.pollOption.name || this.icons.map(icon => icon.text).includes(this.pollOption.name) ) {
        this.pollOption.name = this.icons.find(icon => icon.value == val).text
      }
    }
  }
};

</script>
<template lang="pug">
form(v-on:submit.prevent='submit()')
  v-card.poll-common-option-form(:title="$t(cardTitle)")
    template(v-slot:append)
      dismiss-modal-button
    v-card-text
      div(v-if="hasOptionIcon")
        .text-body-large(v-t="'poll_option_form.icon'")
        .d-flex.mb-4.space-between
          label.poll-option-form__icon.mr-4.d-flex.flex-column.rounded.v-sheet.v-sheet--outlined.voting-enabled(
            v-for="icon in icons"
            :key="icon.value"
            :class="{'poll-option-form__icon-selected': pollOption.icon == icon.value, 'poll-option-form__icon-not-selected': pollOption.icon != icon.value}"
          )
            input(type="radio" :value="icon.value" v-model="pollOption.icon")
            v-avatar(size="48")
              img(:src="'/img/' + icon.value + '.svg'" :alt="icon.text" draggable="false")

        .lmo-validation-error(v-show="pollOption.name && !pollOption.icon")
          span.text-body-small.lmo-validation-error__message(v-t="'poll_option_form.please_select_an_icon'")

      v-text-field.poll-option-form__name.mb-4(
        autofocus
        :label="$t('poll_option_form.option_name')"
        v-model="pollOption.name"
        :hint="$t('poll_option_form.option_name_hint')"
        counter
        :rules="nameRules"
      )
      v-textarea(
        v-if="hasOptionMeaning"
        :label="$t('poll_option_form.meaning')"
        :hint="$t('poll_option_form.meaning_hint')"
        v-model="pollOption.meaning"
        counter="280")
      v-text-field(
        v-if="hasOptionPrompt"
        :label="$t('poll_option_form.prompt')"
        :hint="$t('poll_option_form.prompt_hint')"
        :placeholder="$t('poll_common.reason_placeholder')"
        v-model="pollOption.prompt")

      template(v-if="poll.config().allow_vote_share_requirement")
        v-divider.pb-4
        .text-body-large.pb-2(v-t="'poll_option_form.vote_share_requirement'")
        v-checkbox(
          v-model="testEnabled"
          :label="poll.pollType == 'proposal' ? $t('poll_option_form.for_the_proposal_to_pass') : $t('poll_option_form.for_the_poll_to_be_valid', { poll_type: poll.translatedPollType() })"
        )
        .d-flex.flex-column.flex-sm-row
          v-select.mr-4(
            :disabled="!testEnabled"
            v-model="pollOption.testOperator"
            :items="[{title: $t('poll_option_form.at_least'), value: 'gte'}, {title: $t('poll_option_form.no_more_than'), value: 'lte'}]"
          )

          v-number-input(
            :disabled="!testEnabled"
            v-model="pollOption.testPercent"
            :min="0"
            :max="100"
            :precision="0"
            control-variant="hidden"
            autocomplete="off"
          )
            template(v-slot:append-inner)
              span.mr-4 %
            template(v-slot:append)
              span.mr-4(v-t="'poll_option_form.of'")

          v-select(
            :disabled="!testEnabled"
            v-model="pollOption.testAgainst"
            :items="[{title: $t('poll_option_form.votes_cast'), value: 'score_percent'}, {title: $t('poll_option_form.eligible_voters'), value: 'voter_percent'}]"
          )

    v-divider
    v-card-actions
      v-btn.poll-option-form__done-btn(
        color="primary" variant="elevated"
        @click="submit"
        :disabled="(hasOptionIcon && !pollOption.icon) || !pollOption.name"
      )
        span(v-t="'common.action.done'")
</template>

<style lang="sass">
.poll-option-form__icon-selected
  border: 1px solid var(--v-primary-base) !important

.poll-option-form__icon-not-selected
  opacity: 0.33 !important

.poll-option-form__icon
  cursor: pointer
  border: 1px solid #333
  input
    position: absolute
    opacity: 0
    width: 0
    height: 0

</style>
