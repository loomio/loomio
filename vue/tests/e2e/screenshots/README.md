# User manual screenshots

These Nightwatch specs generate the screenshots committed under
`docs/user_manual/images/`. They are separate from the behavioural E2E suite
and only run when requested.

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

1. Load a deterministic dev scenario.
2. Navigate to the documented state using normal E2E actions.
3. Wait for the content that must appear in the image.
4. Call `manualScreenshot(test).capture('section/name')`.

Use lowercase names containing letters, numbers, hyphens, underscores, and
slashes. The helper disables animations and transitions, resets the scroll
position, and captures a fixed 1280 by 900 pixel browser window by default. Pass
`width` or `height` only when the documented interface requires another size.

Generated images are expected to be reviewed and committed. Do not edit them
by hand; update the scenario or screenshot spec and regenerate them instead.

Use the Oatmilk Cooperative scenarios for the shared user-manual setting. Add
new content to `Dev::Scenarios::OatmilkCooperative` so screenshots keep the
same group, members, purpose, and backstory.
