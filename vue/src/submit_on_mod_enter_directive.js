const states = new WeakMap();

export function isModEnter(event) {
  return event.key === 'Enter' &&
    event.ctrlKey !== event.metaKey &&
    !event.altKey &&
    !event.shiftKey;
}

function beforeMount(element, binding) {
  const state = {submit: binding.value};
  state.onKeydown = (event) => {
    if (!isModEnter(event)) return;

    event.preventDefault();
    event.stopPropagation();
    if (!event.repeat) state.submit(event);
  };

  states.set(element, state);
  element.addEventListener('keydown', state.onKeydown, {capture: true});
}

function updated(element, binding) {
  states.get(element).submit = binding.value;
}

function unmounted(element) {
  const state = states.get(element);
  element.removeEventListener('keydown', state.onKeydown, {capture: true});
  states.delete(element);
}

export default {beforeMount, updated, unmounted};
