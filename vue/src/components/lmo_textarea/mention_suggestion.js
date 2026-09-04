import { onMounted, reactive } from 'vue';
import { uniqBy } from 'lodash-es';
import { VueRenderer } from '@tiptap/vue-3';
import MentionSuggestionList from './mention_suggestion_list.vue';
import { fetchMentionItems, mentionItemsMatching } from './composables/useMentioning';

export function useMentionSuggestion(model) {
  // Prefetch the server's curated results once, filter that cache immediately
  // as the user types, then merge in debounced query results. Tiptap owns the
  // async lifecycle and popup positioning; Loomio owns ordering and matching.
  // Keep the array identity stable: Tiptap holds it as initialItems so the
  // curated list can be prefetched before the first "@" is typed.
  const itemsCached = reactive([]);
  let itemsInitialPromise = null;

  const mergeItems = rows => {
    const merged = uniqBy(itemsCached.concat(rows), 'handle');
    itemsCached.splice(0, itemsCached.length, ...merged);
  };

  const loadItems = async query => {
    const rows = await fetchMentionItems(model.value, query);
    mergeItems(rows);
    return mentionItemsMatching(itemsCached, query);
  };

  const loadInitialItems = () => {
    if (itemsCached.length) { return Promise.resolve(itemsCached); }
    if (itemsInitialPromise) { return itemsInitialPromise; }

    itemsInitialPromise = loadItems('').finally(() => {
      itemsInitialPromise = null;
    });
    return itemsInitialPromise;
  };

  onMounted(loadInitialItems);

  const listProps = props => ({
    command: props.command,
    items: mentionItemsMatching(props.items, props.query),
    loading: props.loading,
    query: props.query
  });

  return {
    HTMLAttributes: {
      class: 'mention'
    },
    suggestion: {
      debounce: 500,
      initialItems: itemsCached,
      items: ({ query }) => query ? loadItems(query.toLowerCase()) : loadInitialItems(),
      render: () => {
        let component = null;
        let unmount = null;

        return {
          onStart: props => {
            component = new VueRenderer(MentionSuggestionList, {
              editor: props.editor,
              props: listProps(props)
            });
            if (component.element) {
              unmount = props.mount(component.element);
            }
          },

          onBeforeUpdate: props => {
            component?.updateProps(listProps(props));
          },

          onUpdate: props => {
            component?.updateProps(listProps(props));
          },

          onKeyDown: props => component?.ref?.onKeyDown(props) || false,

          onExit: () => {
            unmount?.();
            component?.destroy();
            unmount = null;
            component = null;
          }
        };
      }
    }
  };
}
