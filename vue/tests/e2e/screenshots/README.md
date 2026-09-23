# User manual screenshots

These Nightwatch specs generate screenshots in the folder of the manual page
that uses them. They are separate from the behavioural E2E suite and only run
when requested.

Run every screenshot spec:

```sh
bin/e2e-screenshots
```

Run one spec or testcase:

```sh
bin/e2e-screenshots oatmilk_cooperative.js
bin/e2e-screenshots oatmilk_cooperative.js --testcase proposal_discussion
```

Each spec should:

1. Read the complete help page containing the image and identify what the image
   must explain in that context.
2. Load a deterministic dev scenario.
3. Navigate to the documented state using normal E2E actions.
4. Wait for the content that must appear in the image.
5. Call `manualScreenshot(test).capture('path/from/user_manual/name')` for a
   full viewport or `captureElement('path/from/user_manual/name', '.selector')`
   for a focused UI state.

Set the final viewport before opening a menu or dialog. Vuetify overlays retain
the geometry from the viewport in which they opened, so resizing afterward can
make a correctly positioned menu appear detached from its activator.

Use names containing letters, numbers, hyphens, underscores, and slashes;
preserve uppercase letters when an existing manual image uses them. The helper
disables animations and transitions, resets the scroll position, and captures
a fixed 1280 by 900 CSS-pixel browser window by default.
Pass `width` or `height` only when the documented interface requires another size.
The screenshot runner uses a 2× device scale by default, producing twice as
many image pixels in each dimension while preserving those CSS dimensions.
Ordinary behavioural E2E tests continue to run at the browser's default scale.

To spotlight a control, pass its selector with the capture options. The effect
is applied to the PNG after capture, so it does not alter or obstruct the UI:

```js
screenshot.captureElement('groups/settings/group_settings', '.group-page', {
  spotlight: {
    selector: '.action-menu--btn',
    padding: 16,
    radius: 16,
    opacity: 0.4,
    outlineWidth: 0
  }
});
```

The short form `spotlight: '.action-menu--btn'` uses the helper defaults. Keep
spotlights borderless; use generous padding and corner radius when overriding
the defaults.

Framing defaults:

- Capture the full central topic card for discussions, proposals, comments,
  replies, reactions, unread items, and moved-item states; omit app and thread
  drawers unless they are instructional context.
- Omit the application toolbar or title bar unless an application drawer is
  included for instructional context.
- Capture a whole form or modal and spotlight the relevant control.
- Give tightly focused editors, tasks, comments, and menus about 32 CSS pixels
  of external padding, with per-image adjustment where necessary.
- Show both an activator and its open menu, crop after the final meaningful
  action, use light mode, and hide transient flash messages unless the flash is
  the subject of the screenshot.

Example discussion and poll text should normally be about three short
paragraphs and use no more than three deterministic, common formatting features
per record. Reuse the Oatmilk Cooperative profile, logo, bottle, and warehouse
box fixtures. Conceptual illustrations do not belong in Nightwatch, and images
that need representative long-running real-group data (currently the
participation-report graph) remain manual captures.
To spotlight adjacent controls as one region, pass a `selectors` array instead
of `selector`; the helper uses their combined bounding rectangle.

Generated images are expected to be reviewed and committed. Do not edit them
by hand; update the scenario or screenshot spec and regenerate them instead.
Run `bundle exec ruby docs/build.rb` after generating a candidate and before
sharing its localhost documentation URL, because the rendered manual serves
the built copy under `public/docs`.

Use the Oatmilk Cooperative scenarios for the shared user-manual setting. Add
new content to `Dev::Scenarios::OatmilkCooperative` so screenshots keep the
same group, members, purpose, and backstory.
