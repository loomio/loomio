This document aims to explain what we know about developing Loomio.

Loomio started life as a Rails app. Recently we've been developing a javascript front end which communicates with a Rails API.

Note: would be great to break this into Ruby and Javascript development parts.

# Frontend development

## lmo-href
You'll want to use this directive when linking to stuff within the app. it supports command click to open in new window.


## Naming stuff (BEM)

The front end of Loomio is divided into "components" and we have a really simple naming system which helps to keep the codebase easy to use as the application grows. You might have already heard about it, it's called BEM. Here's how we've applied BEM to Loomio:

Components each have a unique name and that name is given to a folder with (typically) 3 files in it: code (Coffeescript) + template (HAML) + stylesheet (SCSS).

You can find the components under `lineman/app/components`.

### Example: thread_preview component

lineman/app/components/thread_preview/
 - thread_preview.coffee
 - thread_preview.haml
 - thread_preview.scss

The first DOM element in your template should have the `.thread-preview` class and all your CSS classes should begin with with `.thread-preview`, for example: `.thread-preview__header`. You don't specify element names (eg: H2, A) and you (almost) never need to nest selectors - so don't do it.

All of this put together has a dramatic effect on your ability to move quickly and write readable code - You always know which file has holds the CSS you want to modify. Want to modify that component? Use your text editors' fuzzy finder to open the file with the component name and the extension you need ie: `thread_preview.scss`, you'll always find what you're looking for and most of the files are pretty small.

The strict CSS name-spacing means that you cannot accidentally effect some other part of the app why styling your component, it also makes it super easy to read and write the DOM. I encourage you to read more about BEM.

#### BEM Do and Don't Examples

Ideally each element has only 1 block/emelment class and maybe a modifier class.

```
Good:
.thread-preview.
and
.thread-preview.thread-preview--visited

Bad:
.thread-preview.selector-list-link.something-else-again
```

This means that we discourage the use of "utility" classes (however you will see them from time to time), instead we put all the style rules needed into the thread-preview class.

```
.thread-preview {
  h2 {
    /* don't do this - ie: don't nest a h2 rule under another class name */
  }
}

.thread-preview__header {
  /* rather.. put a .thread-preview__header class onto your H2 element
}
```

All css class names begin with the unique component name. Eg: thread-preview__header
```
.thread-preview {
  ...
}

.heading {
  /* Wrong way: the class name is not prefixed with the block name */
}

.thread-preview__heading {
  /* correct way of naming a element within the block */
}
```


### Heights, Widths, Padding, Margins

Are you using standard sizes for things? If you find you're typing numbers, then maybe not.

common sizes for things (pies and avarars) tiny: 20, small: 30, medium: 50 large: 80
.lmo-box--tiny
.lmo-box--small
.lmo-box--medium
.lmo-box--large

Padding and spacing is set via:
.lmo-cardPadding
.lmo-thinPadding

Have a look in `lineman/app/components/mixins.scss` and `lineman/app/components/utilities.scss` for commonly used stuff.

### Abbreviations
Please don't use abbreviations. Eg: Write `button` not `btn`. This makes the code easier to read and write - as if abbreviations are in use you can't be sure of spelling.

## Translations
Translations for the AngularJS frontend are currently kept in /config/locales/client.yml. We really want to move each translation into it's component (coming soon). Please follow the same naming scheme as the CSS and don't nest more than once. eg:

```
thread_page:
  heading: 'Thread page'
  context: 'Context'
  edit_button_label: 'Edit'
```

Please use `snake_case` for your translation keys. We have a "common" namespace in the translations file. Please don't use this section for your translations. Always use the BEM namespace for the first part of your translation keys.

## Accessibility (a11y)
We want to make Loomio the most accessible discussion platform available. Making the application accessible requires good knowledge of how to use semantic html tags and WCAG standards, as well as plenty of user feedback and testing.

Checklist
- There should one and only one `h1` per page. It should be the page title.
- There should be one `main` element per page.
- If you have a list of content then use list elements such as `UL` and `LI`
- Be sure to put `alt` attributes on all your images. (Tota11y can check this for you)

Aria labelling:
  todo: technically how and where to use aria labels. eg: labelled by examples. Also guideline for not saying "button" when labelling as screenreader knows this already

Make sure that everything you interact with is a form element or link.
When you write `aria-hidden:true` in haml you need to quote it so `aria-hidden: 'true'`

### Loomio specific accessibly tips

Loomio is visually divided up in to Cards. Each card should be it's own `section` element with an `h2` for the card title. So all cards should start off like so:

```
  %section.members-card{ng-if: 'isMember()', aria-labelledby: 'members-card-title'}
    %h2#members-card-title.lmo-card-heading{ translate: 'members_card.title' }

```

If you're collecting input make sure you use an HTML form and form elements.

A good thing to do is check your work with the [Tota11y](https://khan.github.io/tota11y/) tool - it will give you a checklist of things to fix.

## Design
- Ideally you submit screenshots of the feature with your pull request so that design correctness can be checked easily.
- Please note in the pull request any divergences from the design

## Testing

Currently there are 4 main testing components in Loomio. The rails app is tested with rspec and cucumber. The frontend app is tested with jasmine specs and protractor e2e tests.

Guidelines for writing protractor tests:

- If there is a flash message at the end of a user interaction, testing it showed up is a pretty reliable way to confirm that everything worked.


Rspec / API Controller tests

- API controller specs should test the happy case, invalid model case, and not authorised case.
- API specs should also demonstrate any emails are sent.

## Code - mini version of fog creat code review.
http://blog.fogcreek.com/effective-code-reviews-9-tips-from-a-converted-skeptic/
http://blog.fogcreek.com/increase-defect-detection-with-our-code-review-checklist-example/

Learnings 27 August:
Make sure that everything you interact with is a form element or link.
When you write `aria-hidden:true` in haml you need to quote it so `aria-hidden: 'true'`
