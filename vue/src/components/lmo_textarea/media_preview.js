import { isDraftImagePreview } from './draft_image_preview';

// The editor displays local previews while its document keeps stable URLs.
export function setMediaPreview(element, src, localUrl, poster) {
  if (localUrl) {
    element.removeAttribute('poster');
    element.src = localUrl;
    return;
  }

  if (poster) element.setAttribute('poster', poster);
  element.src = src;
}

export function mediaNodeView(tag, localPreviewUrl) {
  return ({ HTMLAttributes, node }) => {
    const dom = document.createElement(tag);
    const { src, poster, ...attributes } = HTMLAttributes;
    for (const [name, value] of Object.entries(attributes)) {
      dom.setAttribute(name, value);
    }
    if (src) {
      const draftPreview = node.attrs.draftPreview;
      const previewUrl = localPreviewUrl(src) || (isDraftImagePreview(draftPreview) ? draftPreview : null);
      setMediaPreview(dom, src, previewUrl, poster);
    }
    return { dom };
  };
}
