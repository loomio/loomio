// Layout checks read element geometry the way a person sees the page.
export async function box(locator) {
  const rect = await locator.boundingBox();
  if (!rect) { throw new Error(`${locator} is not visible`); }
  return { ...rect, bottom: rect.y + rect.height, right: rect.x + rect.width };
}
