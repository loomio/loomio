Check out this blog story about [Translating Loomio](http://blog.loomio.org/2013/10/01/translating-loomio-2/) for some more context + guidelines for translators.

***
**How to make your feature translation-ready**

Note: In addition to this guide, I highly recommend reading the [Rails I18n documentation](http://guides.rubyonrails.org/i18n.html) for a good introduction to the technology.


All you need to do is pull out any static text from the views, and put them in a locale configuration (config/locale/en.yml) file. This file is automatically synced up to translation management platform [Transifex](http://transifex.com/projects/p/loomio-1/).

So for instance, if you open app/views/help/_how_it_works.html.haml, you’ll see this line
```haml
%h1= t :"help.how_it_works"
```

And in config/locale/en.yml you see:
```yml
help:
	how_it_works: “How it works”
```

This calls the built-in Rails I18n.t function (t for translate), which will look up the appropriate locale file, and return the value for the key help.how_it_works. If the user is viewing the site in English, I18n looks up en.yml and returns the string “How it works”. If the user is Spanish, they’ll see  "Cómo funciona", from the Spanish locale file es.yml.

***
**Namespacing**

Because all the keys live in one big yaml file, we’ve tried to namespace things in a reasonable way, e.g. all the keys on the help page are help.some_key

***
**Passing variables**

You can pass variables like this. In the view:
```haml
= t(:"join_group.header", who: @invitation.inviter_name, group_name: @invitation.group_name)
```

And in the locale file:
```yml
join_group:
  header: “%{who} invited you to join %{group_name}”
```

***
**Rendering HTML**

If you want to render html, just add _html to the end of your key name. Like so:

View:
```haml
%p= t(:want_to_invite_html, link: new_group_invitation_path(@group))
```

Locale file:
```yml
want_to_invite_html: “Want to <a href='%{link}'>invite people</a> to this group?”
```

***
**Style choice: multi-part strings**

In general, longer strings are easier to translate than shorter ones. E.g. rather than splitting this multipart string up into 2 or 3 parts, you’re better to do it in one piece:

View 
```haml
t(:long_string, user_name: “Rich”, action: “editing”, time: Time.now)
```

Locale
```yml
long_string: “%{user_name} finished %{action} at %{time}”
```

***
**Updating strings**

If you ever modify a string, make sure to change its key name at the same time. This will notify the translators that there is a new string to translate.

***
**Gotcha**

You may need to restart the server / dump the app cache every time you add new keys to the locale file.

***
**Locale-setting logic [update needed]**

You can see how the locale setting works in helpers/locales_helper.rb 

The logic is: if the user has a preferred language already set, use that, otherwise check their browser header. 

If we don’t have the user’s language preference (i.e. they are logged out, or they are in the process of creating a new account), we check their browser header and set the locale based on that information.

We have two sets of languages: `Translation.LANGUAGES` are the fully-supported languages (i.e. they are available on the user settings page). `Translation.EXPERIMENTAL_LANGUAGES` are the untested languages - these can be accessed via params, by adding `?locale=XX` to the url of any app page (where XX is the language code).

***

**Deploying a new language on the app [deprecated]** 

When a language has been completed to a first draft stage, the yml file should be added to config/locales, and the name and language code should be added to `Translation.EXPERIMENTAL_LANGUAGES`. 

```
EXPERIMENTAL_LANGUAGES = {"română" => "ro"}
```
Now the translator is directed to view loomio.org/?locale=ro, which will give them access to the Romanian version of the site, without giving that option to the average user. This gives them the chance to make any final changes before we move it out of `EXPERIMENTAL_LANGUAGES` and into the fully supported `LANGUAGES` list.
