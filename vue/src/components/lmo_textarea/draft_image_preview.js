const JPEG_DATA_URL_PREFIX = 'data:image/jpeg;base64,';
const ENCODED_PREVIEW_SIZE_MAX = 256 * 1024;

export function isDraftImagePreview(value) {
  return typeof value === 'string' && value.length <= ENCODED_PREVIEW_SIZE_MAX &&
    value.startsWith(JPEG_DATA_URL_PREFIX);
}

function resizeDraftImage(image) {
  if (!image.naturalWidth || !image.naturalHeight) return null;

  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d', { alpha: false });
  if (!context) return null;

  // The cap covers the base64 string carried by the collaboration document.
  for (const dimensionMax of [1024, 768, 512, 256]) {
    const scale = Math.min(1, dimensionMax / Math.max(image.naturalWidth, image.naturalHeight));
    canvas.width = Math.max(1, Math.round(image.naturalWidth * scale));
    canvas.height = Math.max(1, Math.round(image.naturalHeight * scale));
    context.fillStyle = '#fff';
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.drawImage(image, 0, 0, canvas.width, canvas.height);

    const preview = canvas.toDataURL('image/jpeg', 0.7);
    if (isDraftImagePreview(preview)) return preview;
  }
  return null;
}

export async function prepareDraftImage(localUrl) {
  const image = new Image();
  image.src = localUrl;
  try {
    await image.decode();
    return {
      width: image.naturalWidth,
      height: image.naturalHeight,
      preview: resizeDraftImage(image)
    };
  } catch {
    return null;
  }
}
