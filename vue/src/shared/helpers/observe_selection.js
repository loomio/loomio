const callbacks = new Map();

function selectionChanged() {
  const selection = window.getSelection();
  if (!selection?.rangeCount || selection.isCollapsed) return;
  let element = selection.anchorNode.nodeType === Node.ELEMENT_NODE ? selection.anchorNode : selection.anchorNode.parentElement;
  while (element) {
    const callback = callbacks.get(element);
    if (callback) {
      callback(selection.getRangeAt(0).cloneRange());
      return;
    }
    element = element.parentElement;
  }
}

// Native find and text selection share one listener across preview bodies.
export function observeSelection(element, callback) {
  if (callbacks.size === 0) document.addEventListener('selectionchange', selectionChanged);
  callbacks.set(element, callback);
  return () => {
    callbacks.delete(element);
    if (callbacks.size === 0) document.removeEventListener('selectionchange', selectionChanged);
  };
}
