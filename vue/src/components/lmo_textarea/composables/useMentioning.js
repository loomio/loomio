import { ref, onMounted } from 'vue';
import { sortBy, filter, uniqBy, debounce } from 'lodash-es';
import Records from '@/shared/services/records';
import getCaretCoordinates from 'textarea-caret';

export function useCommonMentioning(model) {
  const mentionsCache = ref([]);
  const mentions = ref([]);
  const query = ref('');
  const navigatedUserIndex = ref(0);
  const suggestionListStyles = ref({});
  const fetchingMentions = ref(false);

  const fetchMentionable = debounce(function() {
    if (!query.value && mentionsCache.value.length > 0) { return; }
    fetchingMentions.value = true;
    const namedId = (model.value.discussionId && model.value.discussion().namedId()) ||
      (model.value.id && model.value.namedId()) ||
      (model.value.groupId && model.value.group().namedId()) ||
      {};
    Records.remote.get('mentions', Object.assign(namedId, { q: query.value })).then(rows => {
      mentionsCache.value = uniqBy(mentionsCache.value.concat(rows), 'handle');
      updateMentions();
    }).finally(() => {
      fetchingMentions.value = false;
    });
  }, 500);

  onMounted(() => {
    fetchMentionable();
  });

  const updateMentions = () => {
    if (!query.value) {
      mentions.value = mentionsCache.value;
    } else {
      const unsorted = filter(mentionsCache.value, u => {
        return (u.name || '').toLowerCase().startsWith(query.value) ||
                (u.handle || '').toLowerCase().startsWith(query.value) ||
                (u.name || '').toLowerCase().includes(` ${query.value}`);
      });
      mentions.value = sortBy(unsorted, row => row.name);
    }
  };

  return {
    mentionsCache,
    mentions,
    query,
    navigatedUserIndex,
    suggestionListStyles,
    fetchingMentions,
    fetchMentionable,
    updateMentions
  };
}

export function useMdMentioning(model, field, textarea, query, mentions, navigatedUserIndex, suggestionListStyles, fetchMentionable, updateMentions) {
  const onKeyUp = (event) => {
    if ([38, 40, 13, 9].includes(event.keyCode)) { return; }
    const res = textarea.value.value.slice(0, textarea.value.selectionStart).match(/@(\w+)$/);
    if (res) {
      query.value = res[1].toLowerCase();
      fetchMentionable();
      updateMentions();
      respondToKey(event);
      return updatePopup();
    } else {
      return query.value = '';
    }
  };

  const onKeyDown = (event) => {
    if (query.value) { return respondToKey(event); }
  };

  const respondToKey = (event) => {
    if (event.keyCode === 38) {
      navigatedUserIndex.value = ((navigatedUserIndex.value + mentions.value.length) - 1) % mentions.value.length;
      event.preventDefault();
    }

    // down
    if (event.keyCode === 40) {
      navigatedUserIndex.value = (navigatedUserIndex.value + 1) % mentions.value.length;
      event.preventDefault();
    }

    // enter or tab
    if ([13, 9].includes(event.keyCode)) {
      let user;
      if (user = mentions.value[navigatedUserIndex.value]) {
        selectRow(user);
        query.value = '';
        event.preventDefault();
      }
    }
  };

  const selectRow = (user) => {
    const text = textarea.value.value;
    const beforeText = textarea.value.value.slice(0, textarea.value.selectionStart - query.value.length);
    const afterText = textarea.value.value.slice(textarea.value.selectionStart);
    model.value[field.value] = beforeText + user.handle + ' ' + afterText;
    textarea.value.selectionEnd = (beforeText + user.handle).length + 1;
    textarea.value.focus();
    query.value = '';
  };

  const updatePopup = () => {
    if (!textarea.value) { return; }
    const coords = getCaretCoordinates(textarea.value, textarea.value.selectionStart - query.value.length);
    suggestionListStyles.value = {
      position: 'absolute',
      top: ((coords.top - textarea.value.scrollTop) + coords.height + 16) + 'px',
      left: coords.left + 'px'
    };
  };

  return {
    onKeyUp,
    onKeyDown,
    respondToKey,
    selectRow,
    updatePopup
  };
}

export function useHtmlMentioning(editor, query, mentions, navigatedUserIndex, suggestionListStyles, fetchMentionable, updateMentions) {
  const suggestionRange = ref(null);
  const insertMention = ref(() => ({}));

  const upHandler = () => {
    navigatedUserIndex.value = ((navigatedUserIndex.value + mentions.value.length) - 1) % mentions.value.length;
  };

  const downHandler = () => {
    navigatedUserIndex.value = (navigatedUserIndex.value + 1) % mentions.value.length;
  };

  const enterHandler = () => {
    const row = mentions.value[navigatedUserIndex.value];
    if (row) { selectRow(row); }
  };

  const selectRow = (row) => {
    insertMention.value({
      id: row.handle,
      label: row.name
    });
    editor.value.chain().focus();
  };

  const updatePopup = (coords) => {
    suggestionListStyles.value = {
      position: 'fixed',
      top: coords.y + 24 + 'px',
      left: coords.x + 'px'
    };
  };

  return {
    suggestionRange,
    insertMention,
    upHandler,
    downHandler,
    enterHandler,
    selectRow,
    updatePopup
  };
}

export function getMentionPluginConfig(context) {
  return {
    HTMLAttributes: {
      class: 'mention'
    },
    suggestion: {
      render: () => {
        return {
          onStart: props => {
            context.query.value = props.query.toLowerCase();
            context.suggestionRange.value = props.range;
            context.insertMention.value = props.command;
            context.updatePopup(props.clientRect());
            context.fetchMentionable();
            context.updateMentions();
          },

          onUpdate: props => {
            context.query.value = props.query.toLowerCase();
            context.suggestionRange.value = props.range;
            context.insertMention.value = props.command;
            context.navigatedUserIndex.value = 0;
            context.updatePopup(props.clientRect());
            context.fetchMentionable();
            context.updateMentions();
          },

          onExit: props => {
            context.query.value = null;
            context.suggestionRange.value = null;
            context.navigatedUserIndex.value = 0;
          },

          onKeyDown: props => {
            // pressing up arrow
            if (props.event.keyCode === 38) {
              context.upHandler();
              return true;
            }

            // pressing down arrow
            if (props.event.keyCode === 40) {
              context.downHandler();
              return true;
            }

            // pressing enter or tab
            if ([13, 9].includes(props.event.keyCode)) {
              context.enterHandler();
              return true;
            }

            return false;
          }
        };
      }
    }
  };
}
