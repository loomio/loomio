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

export function mentionItemsMatching(items, query) {
  const queryNormalized = (query || '').toLowerCase();
  if (!queryNormalized) { return items; }

  const matchingItems = filter(items, item => {
    const name = (item.name || '').toLowerCase();
    const handle = (item.handle || '').toLowerCase();
    return name.startsWith(queryNormalized) ||
           handle.startsWith(queryNormalized) ||
           name.includes(` ${queryNormalized}`);
  });

  return sortBy(matchingItems, item => {
    const name = (item.name || '').toLowerCase();
    const handle = (item.handle || '').toLowerCase();
    return name.startsWith(queryNormalized) || handle.startsWith(queryNormalized) ? 0 : 1;
  });
}

export function fetchMentionItems(model, query) {
  return Records.remote.get('mentions', {
    ...mentionNamedIdFor(model),
    q: query
  });
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
    fetchMentionItems(model.value, query.value).then(rows => {
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
    mentions.value = mentionItemsMatching(mentionsCache.value, query.value);
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
    const res = textarea.value.value.slice(0, textarea.value.selectionStart).match(/@([a-z0-9_-]*)$/i);
    if (res) {
      query.value = res[1].toLowerCase();
      fetchMentionable();
      updateMentions();
      respondToKey(event);
      return updatePopup();
    } else {
      return query.value = null;
    }
  };

  const onKeyDown = (event) => {
    if (query.value !== null) { return respondToKey(event); }
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
        query.value = null;
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
