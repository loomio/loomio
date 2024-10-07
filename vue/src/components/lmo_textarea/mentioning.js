import {sortBy, filter, uniq, map, debounce} from 'lodash-es';
import Records from '@/shared/services/records';
import getCaretCoordinates from 'textarea-caret';

export var CommonMentioning = {
  data() {
    return {
      mentionableUserIds: [],
      mentionable: [],
      query: '',
      navigatedUserIndex: 0,
      suggestionListStyles: {},
      fetchingMentions: false
    };
  },

  mounted() {
    this.fetchMentionable = debounce(function() {
      if (!this.query) { return; }
      this.fetchingMentions = true;
      return Records.users.fetchMentionable(this.query, this.model).then(response => {
        this.fetchingMentions = false;
        this.mentionableUserIds = uniq(this.mentionableUserIds.concat(map(response.users, 'id')));
        return this.findMentionable();
      });
    }
    ,
      500);
  },

  methods: {
    findMentionable() {
      const audiences = [
                          { id: 'discussion', translation: this.$t('mentioning.discussion'), audience: true },
                          { id: 'group', translation: this.$t('mentioning.group'), audience: true }
                        ].filter(audience => audience.translation.startsWith(this.query))
      this.mentionableUserIds = uniq(this.mentionableUserIds.concat(this.model.participantIds()));
      const unsorted = filter(Records.users.collection.chain().find({id: {$in: this.mentionableUserIds}}).data(), u => {
        return ((u.name || '').toLowerCase().startsWith(this.query) ||
        (u.username || '').toLowerCase().startsWith(this.query) ||
        (u.name || '').toLowerCase().includes(` ${this.query}`));
      });
      this.mentionable = audiences.concat(sortBy(unsorted, u => 0 - Records.events.find({actorId: u.id}).length));
    }
  }
};

export var MdMentioning = {
  methods: {
    textarea() {
      return this.$refs.field.$el.querySelector('textarea');
    },

    onKeyUp(event) {
      const res = this.textarea().value.slice(0, this.textarea().selectionStart).match(/@(\w+)$/);
      if (res) {
        this.query = res[1].toLowerCase();
        this.fetchMentionable();
        this.findMentionable();
        this.respondToKey(event);
        return this.updatePopup();
      } else {
        return this.query = '';
      }
    },

    onKeyDown(event) {
      if (this.query) { return this.respondToKey(event); }
    },

    respondToKey(event) {
      if (event.keyCode === 38) {
        this.navigatedUserIndex = ((this.navigatedUserIndex + this.mentionable.length) - 1) % this.mentionable.length;
        event.preventDefault();
      }

      // down
      if (event.keyCode === 40) {
        this.navigatedUserIndex = (this.navigatedUserIndex + 1) % this.mentionable.length;
        event.preventDefault();
      }

      // enter or tab
      if ([13,9].includes(event.keyCode)) {
        let user;
        if (user = this.mentionable[this.navigatedUserIndex]) {
          this.selectMentionable(user);
          this.query = '';
          event.preventDefault();
        }
      }
    },

    selectMentionable(mention) {
      const text = this.textarea().value;
      const beforeText = this.textarea().value.slice(0, this.textarea().selectionStart - this.query.length);
      const afterText = this.textarea().value.slice(this.textarea().selectionStart);
      this.model[this.field] = beforeText + mention.username + ' ' + afterText;
      this.textarea().selectionEnd = (beforeText + mention.username).length + 1;
      this.textarea().focus;
      this.query = '';
    },

    updatePopup() {
      if (!this.$refs.field) { return; }
      const coords = getCaretCoordinates(this.textarea(), this.textarea().selectionStart - this.query.length);
      this.suggestionListStyles = {
        position: 'absolute',
        top: ((coords.top - this.textarea().scrollTop) + coords.height + 16) + 'px',
        left: coords.left + 'px'
      };
    }
  }
};

export var HtmlMentioning = {
  data() {
    return {suggestionRange: null};
  },

  created() {
    this.insertMention = () => ({});
  },

  methods: {
    upHandler() {
      this.navigatedUserIndex = ((this.navigatedUserIndex + this.mentionable.length) - 1) % this.mentionable.length;
    },

    downHandler() {
      this.navigatedUserIndex = (this.navigatedUserIndex + 1) % this.mentionable.length;
    },

    enterHandler() {
      const user = this.mentionable[this.navigatedUserIndex];
      if (user) { this.selectMentionable(user); }
    },

    selectMentionable(mention) {
      // range: @suggestionRange
      // attrs:
      this.insertMention({
        id: mention.audience ? mention.id : mention.username,
        label: mention.audience ? mention.translation : mention.name
      });
      this.editor.chain().focus();
    },

    updatePopup(coords) {
      // return unless node
      // coords = node.getBoundingClientRect()
      this.suggestionListStyles = {
        position: 'fixed',
        top: coords.y + 24 + 'px',
        left: coords.x + 'px'
      };
    }
  }
};

export var MentionPluginConfig = function() {
  // is called when a suggestion starts
  return {
    HTMLAttributes: {
      class: 'mention'
    },
    suggestion: {
      render: () => {
        return {
          onStart: props => {
            this.query = props.query.toLowerCase();
            this.suggestionRange = props.range;
            this.insertMention = props.command;
            this.updatePopup(props.clientRect());
            this.fetchMentionable();
            this.findMentionable();
          },

          // is called when a suggestion has changed
          onUpdate: props => {
            this.query = props.query.toLowerCase();
            this.suggestionRange = props.range;
            this.insertMention = props.command;
            this.navigatedUserIndex = 0;
            this.updatePopup(props.clientRect());
            this.fetchMentionable();
            this.findMentionable();
          },

          // is called when a suggestion is cancelled
          onExit: props => {
            this.query = null;
            this.suggestionRange = null;
            this.navigatedUserIndex = 0;
          },

          // is called on every keyDown event while a suggestion is active
          onKeyDown: props => {
            // pressing up arrow
            if (props.event.keyCode === 38) {
              this.upHandler();
              return true;
            }

            // pressing down arrow
            if (props.event.keyCode === 40) {
              this.downHandler();
              return true;
            }

            // pressing enter or tab
            if ([13,9].includes(props.event.keyCode)) {
              this.enterHandler();
              return true;
            }

            return false;
          }
        };
      }
    }
  };
};
