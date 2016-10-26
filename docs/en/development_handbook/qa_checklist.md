# Loomio QA checklist template
Copy this into the context panel of a QA thread.
Deploy your feature branch to a public test environment, provide a link to the environment and give instructions about how to test the feature.

When testers have checked aspects of the branch, they should add a √ symbol to the box of the corresponding line.


## Smoke test

A developer who did not build the feature should check that:

- happy path works
- sad paths work
- invalid data gives appropriate response.

## Code review:

- BEM is correctly used in the CSS
- all strings been extracted into translation files
- the right amount of unit tests are present and passing
- there are e2e tests to confirm the feature works
- a green apple has been given
- images are the right size for the job
- have you read https://github.com/ankane/secure_rails recently?

## Browser Compatibility

desktop:
- Chrome
- Firefox
- Safari
- IE/Edge

mobile:
- chrome
- firefox
- safari

## Accessibility

See the [a11y guide](accessibility.md) for more info.
- headings are semantic
- titles are present on links
- alt tags on images
- key sections have aria labels
- screen reader based operation is possible

## Production readyness
- does the user help manual need updating?
- deployment to loomio-clone ok
- background jobs for things that take time or use external services.
- intercom behaves correctly
- google analytics records actions
- background jobs have crontasks
- migrations have been tested on a copy of the production database

## Open source ready
- The code does not contain any Loomio.org specific stuff
- The design makes sense when used on domains other than loomio.org

## Emails
- Have as simple as can be HTML & CSS confirming to BEM where possible
- Are within the max width of 600px

## After deploy, test on production if:
- code touches groups, check you can start a group from the homepage
- code touches payments, check you can start a subscription. (ask mhjb for 100% discount code)
