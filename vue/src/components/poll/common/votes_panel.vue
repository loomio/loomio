<script lang="js">
import PageLoader         from '@/shared/services/page_loader';
import Records from '@/shared/services/records';
import EventBus     from '@/shared/services/event_bus';
import { parseISO } from 'date-fns';
import { debounce } from 'lodash-es';
import I18n from '@/i18n';

export default {
  props: {
    poll: Object
  },

  data() {
    return {
      stances: [],
      per: 25,
      loader: null,
      pollOptionItems: [{text: I18n.t('discussions_panel.all'), value: null}].concat(this.poll.pollOptions().map((o, i) => { 
        return {text: o.optionName(), value: o.id};
      })),
      page: parseInt(this.$route.query.page) || 1, 
      pollOptionId: parseInt(this.$route.query.poll_option_id) || null,
      name: this.$route.query.name
    };
  },

  mounted() {
    this.fetchNow();
  },

  computed: {
    totalPages() {
      return Math.ceil(parseFloat(this.loader.total) / parseFloat(this.per));
    }
  },

  watch: {
    page(val, lastVal) {
      if (val === lastVal) { return; }
      this.$router.replace({query: Object.assign({}, this.$route.query, {page: val})}); 
      this.fetch();
    },

    pollOptionId(val, lastVal) {
      if (val === lastVal) { return; }
      this.page = 1;
      this.name = null;
      this.$router.replace({query: Object.assign({}, this.$route.query, {poll_option_id: val, name: null})}); 
      this.fetch();
    }
  },

  methods: {
    nameChanged() {
      this.$router.replace({query: Object.assign({}, this.$route.query, {name: this.name})}); 
      this.fetch();
    },

    fetch: debounce(function() {
      this.fetchNow();
    } , 50),

    fetchNow() {
      this.loader = new PageLoader({
        path: 'stances',
        order: 'orderAt',
        params: {
          per: this.per,
          poll_id: this.poll.id,
          poll_option_id: this.pollOptionId,
          name: this.name
        }
      });
      this.loader.fetch(this.page).then(() => this.findRecords()).then(() => this.scrollTo('#votes'));
    },


    findRecords() {
      if (this.loader.pageWindow[this.page]) {
        let chain = Records.stances.collection.chain().find({id: {$in: this.loader.pageIds[this.page]}});
        chain = chain.simplesort('orderAt', true);
        this.stances = chain.data();
      } else {
        this.stances = [];
      }
    }
  }
};

</script>

<template lang="pug">
.poll-common-votes-panel
  //- v-layout.poll-common-votes-panel__header
    //- v-select(style="max-width: 200px" dense solo v-model='order' :items="sortOptions" @change='refresh()' aria-label="$t('poll_common_votes_panel.change_results_order')")
  h2.text-h5.my-2#votes(v-t="'poll_common.votes'")
  .d-flex
    v-select.mr-2(:items="pollOptionItems" :label="$t('common.option')" v-model="pollOptionId")
    v-text-field(v-if="!poll.anonymous" v-model="name" @change="nameChanged" :label="$t('poll_common_votes_panel.name_or_username')")
  .poll-common-votes-panel__no-votes.text--secondary(v-if='!poll.votersCount' v-t="'poll_common_votes_panel.no_votes_yet'")
  .poll-common-votes-panel__has-votes(v-if='poll.votersCount')
    .poll-common-votes-panel__stance(v-for='stance in stances', :key='stance.id')
      .poll-common-votes-panel__avatar.pr-3
        user-avatar(:user='stance.participant()', :size='24')
      .poll-common-votes-panel__stance-content
        .poll-common-votes-panel__stance-name-and-option
          v-layout.text-body-2(align-center)
            span.text--secondary {{ stance.participantName() }}
            span(v-if="poll.showResults() && stance.castAt && poll.hasOptionIcon()")
              poll-common-stance-choice.pl-2.pr-1(
                :poll="poll", 
                :stance-choice="stance.stanceChoice()")
              space
            span(v-if='!stance.castAt' )
              space
              span(v-t="'poll_common_votes_panel.undecided'" )
            span(v-if="stance.castAt")
              mid-dot(v-if="!poll.hasOptionIcon()")
              time-ago.text--secondary(:date="stance.castAt")
        .poll-common-stance(v-if="poll.showResults() && stance.castAt")
          poll-common-stance-choices(:stance='stance')
          formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
    loading(v-if="loader.loading")
    v-pagination(v-model="page", :length="totalPages", :disabled="totalPages == 1")
</template>

<style lang="sass">
.poll-common-votes-panel__stance
	display: flex
	align-items: flex-start
	margin: 7px 0

</style>
