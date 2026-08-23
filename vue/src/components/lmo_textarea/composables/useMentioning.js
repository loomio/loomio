import { ref, onMounted } from 'vue';
import { sortBy, filter, uniqBy, debounce } from 'lodash-es';
import Records from '@/shared/services/records';
import getCaretCoordinates from 'textarea-caret';

export function mentionNamedIdFor(model) {
  if (model.isA('comment')) {
    return model.topic().namedId();
  }

  if (model.isA('stance', 'outcome')) {
    return model.poll().topic().namedId();
  }

  if (model.topicId) {
    return model.topic().namedId();
  }

  if (model.groupId) {
    return model.group().namedId();
  }

  if (model.isA('group') && model.id) {
    return model.namedId();
  }

  return {};
}

export function useCommonMentioning(model) {
  const mentionsCache = ref([]);
  const mentions = ref([]);
  const query = ref(null);
  const navigatedUserIndex = ref(0);
  const suggestionListStyles = ref({});
  const fetchingMentions = ref(false);

  const fetchMentionableNow = () => {
    if (!query.value && mentionsCache.value.length > 0) { return; }
    fetchingMentions.value = true;
    const namedId = mentionNamedIdFor(model.value);
    Records.remote.get('mentions', Object.assign(namedId, { q: query.value })).then(rows => {
      mentionsCache.value = uniqBy(mentionsCache.value.concat(rows), 'handle');
      updateMentions();
    }).finally(() => {
      fetchingMentions.value = false;
    });
  };

  const fetchMentionable = debounce(fetchMentionableNow, 500);

  onMounted(() => {
    fetchMentionableNow();
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
      mentions.value = sortBy(unsorted, row => {
        const name = (row.name || '').toLowerCase();
        const handle = (row.handle || '').toLowerCase();
        return name.startsWith(query.value) || handle.startsWith(query.value) ? 0 : 1;
      });
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
  const onKeyUp = (topic_item) => {
    if ([38, 40, 13, 9].includes(topic_item.keyCode)) { return; }
    const res = textarea.value.value.slice(0, textarea.value.selectionStart).match(/@([a-z0-9_-]*)$/i);
    if (res) {
      query.value = res[1].toLowerCase();
      fetchMentionable();
      updateMentions();
      respondToKey(topic_item);
      return updatePopup();
    } else {
      return query.value = null;
    }
  };

  const onKeyDown = (topic_item) => {
    if (query.value !== null) { return respondToKey(topic_item); }
  };

  const respondToKey = (topic_item) => {
    if (topic_item.keyCode === 38) {
      navigatedUserIndex.value = ((navigatedUserIndex.value + mentions.value.length) - 1) % mentions.value.length;
      topic_item.preventDefault();
    }

    // down
    if (topic_item.keyCode === 40) {
      navigatedUserIndex.value = (navigatedUserIndex.value + 1) % mentions.value.length;
      topic_item.preventDefault();
    }

    // enter or tab
    if ([13, 9].includes(topic_item.keyCode)) {
      let user;
      if (user = mentions.value[navigatedUserIndex.value]) {
        selectRow(user);
        query.value = null;
        topic_item.preventDefault();
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
    query.value = null;
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
    editor.value.chain().focus().run();
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
            if (props.topic_item.keyCode === 38) {
              context.upHandler();
              return true;
            }

            // pressing down arrow
            if (props.topic_item.keyCode === 40) {
              context.downHandler();
              return true;
            }

            // pressing enter or tab
            if ([13, 9].includes(props.topic_item.keyCode)) {
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
