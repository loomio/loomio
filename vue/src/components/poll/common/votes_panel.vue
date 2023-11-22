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

  created() {
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

<template>

<div class="poll-common-votes-panel">
  <h2 class="text-h5 my-2" id="votes" v-t="'poll_common.votes'"></h2>
  <div class="d-flex">
    <v-select class="mr-2" :items="pollOptionItems" :label="$t('common.option')" v-model="pollOptionId"></v-select>
    <v-text-field v-if="!poll.anonymous" v-model="name" @change="nameChanged" :label="$t('poll_common_votes_panel.name_or_username')"></v-text-field>
  </div>
  <div class="poll-common-votes-panel__no-votes text--secondary" v-if="!poll.votersCount" v-t="'poll_common_votes_panel.no_votes_yet'"></div>
  <div class="poll-common-votes-panel__has-votes" v-if="poll.votersCount">
    <div class="poll-common-votes-panel__stance" v-for="stance in stances" :key="stance.id">
      <div class="poll-common-votes-panel__avatar pr-3">
        <user-avatar :user="stance.participant()" :size="24"></user-avatar>
      </div>
      <div class="poll-common-votes-panel__stance-content">
        <div class="poll-common-votes-panel__stance-name-and-option">
          <v-layout class="text-body-2" align-center="align-center"><span class="text--secondary">{{ stance.participantName() }}</span><span v-if="poll.showResults() && stance.castAt && poll.hasOptionIcon()">
              <poll-common-stance-choice class="pl-2 pr-1" :poll="poll" :stance-choice="stance.stanceChoice()"></poll-common-stance-choice>
              <space></space></span><span v-if="!stance.castAt">
              <space></space><span v-t="'poll_common_votes_panel.undecided'"></span></span><span v-if="stance.castAt">
              <mid-dot v-if="!poll.hasOptionIcon()"></mid-dot>
              <time-ago class="text--secondary" :date="stance.castAt"></time-ago></span></v-layout>
        </div>
        <div class="poll-common-stance" v-if="poll.showResults() && stance.castAt">
          <poll-common-stance-choices :stance="stance"></poll-common-stance-choices>
          <formatted-text class="poll-common-stance-created__reason" :model="stance" column="reason"></formatted-text>
        </div>
      </div>
    </div>
    <loading v-if="loader.loading"></loading>
    <v-pagination v-model="page" :length="totalPages" :disabled="totalPages == 1"></v-pagination>
  </div>
</div>
</template>

<style lang="sass">
.poll-common-votes-panel__stance
	display: flex
	align-items: flex-start
	margin: 7px 0

</style>
