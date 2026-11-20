// The editor displays local previews while its document keeps stable URLs.
export function setMediaPreview(element, src, localPreviewUrl, poster) {
  const localUrl = localPreviewUrl(src);
  if (localUrl) {
    element.removeAttribute('poster');
    element.src = localUrl;
    return;
  }

  if (poster) element.setAttribute('poster', poster);
  element.src = src;
}

export function mediaNodeView(tag, localPreviewUrl, restorePreview) {
  return ({ HTMLAttributes }) => {
    const dom = document.createElement(tag);
    const { src, poster, ...attributes } = HTMLAttributes;
    for (const [name, value] of Object.entries(attributes)) {
      dom.setAttribute(name, value);
    }
    if (!src) return { dom };

    const pendingPreview = !localPreviewUrl(src) && restorePreview?.(src);
    if (!pendingPreview) {
      setMediaPreview(dom, src, localPreviewUrl, poster);
      return { dom };
    }

    let objectUrl;
    let destroyed = false;
    pendingPreview.then(file => {
      if (destroyed) return;

      if (file) objectUrl = URL.createObjectURL(file);
      dom.src = objectUrl || src;
    });
    return {
      dom,
      destroy() {
        destroyed = true;
        if (objectUrl) URL.revokeObjectURL(objectUrl);
      }
    };
  };
}
