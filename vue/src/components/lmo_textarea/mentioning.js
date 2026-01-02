import {sortBy, filter, uniq, uniqBy, debounce} from 'lodash-es';
import Records from '@/shared/services/records';
import getCaretCoordinates from 'textarea-caret';

export var CommonMentioning = {
  data() {
    return {
      mentionsCache: [],
      mentions: [],
      query: '',
      navigatedUserIndex: 0,
      suggestionListStyles: {},
      fetchingMentions: false
    };
  },

  mounted() {
    this.fetchMentionable = debounce(function() {
      if (!this.query && this.mentionsCache.length > 0) { return; }
      this.fetchingMentions = true;
      const namedId = (this.model.discussionId && this.model.discussion().namedId()) ||
        (this.model.id && this.model.namedId()) ||
        (this.model.groupId && this.model.group().namedId()) ||
        {};
      Records.remote.get('mentions', Object.assign(namedId, { q: this.query })).then(rows => {
        this.mentionsCache = uniqBy(this.mentionsCache.concat(rows), 'handle');
        this.updateMentions();
      }).finally(() => {
        this.fetchingMentions = false;
      })
    } , 500);
    this.fetchMentionable();
  },

  methods: {
    updateMentions() {
      if (!this.query) {
        this.mentions = this.mentionsCache;
      } else {
        const unsorted = filter(this.mentionsCache, u => {
          return (u.name || '').toLowerCase().startsWith(this.query) ||
                  (u.handle || '').toLowerCase().startsWith(this.query) ||
                  (u.name || '').toLowerCase().includes(` ${this.query}`);
        });
        this.mentions = sortBy(unsorted, row => row.name);
      }
    }
  }
};

export var MdMentioning = {
  methods: {
    textarea() {
      return this.$refs.field.$el.querySelector('textarea');
    },

    onKeyUp(event) {
      if ([38, 40, 13, 9].includes(event.keyCode)) { return }
      const res = this.textarea().value.slice(0, this.textarea().selectionStart).match(/@(\w+)$/);
      if (res) {
        this.query = res[1].toLowerCase();
        this.fetchMentionable();
        this.updateMentions();
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
        this.navigatedUserIndex = ((this.navigatedUserIndex + this.mentions.length) - 1) % this.mentions.length;
        event.preventDefault();
      }

      // down
      if (event.keyCode === 40) {
        this.navigatedUserIndex = (this.navigatedUserIndex + 1) % this.mentions.length;
        event.preventDefault();
      }

      // enter or tab
      if ([13,9].includes(event.keyCode)) {
        let user;
        if (user = this.mentions[this.navigatedUserIndex]) {
          this.selectRow(user);
          this.query = '';
          event.preventDefault();
        }
      }
    },

    selectRow(user) {
      const text = this.textarea().value;
      const beforeText = this.textarea().value.slice(0, this.textarea().selectionStart - this.query.length);
      const afterText = this.textarea().value.slice(this.textarea().selectionStart);
      this.model[this.field] = beforeText + user.handle + ' ' + afterText;
      this.textarea().selectionEnd = (beforeText + user.handle).length + 1;
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
      this.navigatedUserIndex = ((this.navigatedUserIndex + this.mentions.length) - 1) % this.mentions.length;
    },

    downHandler() {
      this.navigatedUserIndex = (this.navigatedUserIndex + 1) % this.mentions.length;
    },

    enterHandler() {
      const row = this.mentions[this.navigatedUserIndex];
      if (row) { this.selectRow(row); }
    },

    selectRow(row) {
      this.insertMention({
        id: row.handle,
        label: row.name
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
            this.updateMentions();
          },

          // is called when a suggestion has changed
          onUpdate: props => {
            this.query = props.query.toLowerCase();
            this.suggestionRange = props.range;
            this.insertMention = props.command;
            this.navigatedUserIndex = 0;
            this.updatePopup(props.clientRect());
            this.fetchMentionable();
            this.updateMentions();
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
