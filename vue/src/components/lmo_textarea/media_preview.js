// The editor stores stable URLs in its document. Only the displayed element
// uses a local URL, or requests the uploader's temporary preview after reload.
const ordinaryMediaPath = /^\/rails\/active_storage\/(?:blobs\/(?:redirect\/|proxy\/)?([^/]+)\/|representations\/(?:redirect\/|proxy\/)?([^/]+)\/[^/]+\/)[^?#]+(?:[?#].*)?$/;

export function setMediaPreview(element, src, localPreviewUrl, poster) {
  const localUrl = localPreviewUrl(src);
  if (localUrl) {
    element.src = localUrl;
    return;
  }

  const match = ordinaryMediaPath.exec(src);
  if (match) {
    const [, blobId, representationBlobId] = match;
    element.addEventListener('error', () => {
      element.removeAttribute('poster');
      element.src = `/draft_uploads/${blobId || representationBlobId}`;
    }, { once: true });
  }
  if (poster) element.setAttribute('poster', poster);
  element.src = src;
}

export function mediaNodeView(tag, localPreviewUrl) {
  return ({ HTMLAttributes }) => {
    const dom = document.createElement(tag);
    const { src, poster, ...attributes } = HTMLAttributes;
    for (const [name, value] of Object.entries(attributes)) {
      dom.setAttribute(name, value);
    }
    if (src) setMediaPreview(dom, src, localPreviewUrl, poster);
    return { dom };
  };
}
