You're here becuase you want to learn how to translate Loomio. Yay!

## We use Transifex

We use Transifex to manage our translation process (an excellent service that's free for open-source projects).

### Sign up to Transifex

Visit the [Loomio Transifex page](https://www.transifex.com/projects/p/loomio-1/). Click the blue button: "Help Translate Loomio" then ask to join a translation.

### The basics

1. Visit the [Loomio Transifex page](https://www.transifex.com/projects/p/loomio-1/), and select your language

2. Select the resource you want to translate
- Client is the front end code that your browser runs.
- Server is the backend server code, which is mostly notification emails.
- Marketing is the loomio.org front page which explains Loomio to the world.

3. Click 'Translate'

4. 
- click on a phrases
- read the english text 
- enter your translation 
- save and repeat

## How to correctly translate code:

When you combine a translation string with some personal data you get something the user will understand. To make this work there are little bits of code within translation strings. It' takes a little practice to learn how to work with them.

### HTML tags:

`<h2>`, `<p>`, and `<a>` are html tags which describe if text is a heading, paragraph, link, and so on. There are often matching `</h2>`, `</p>`, and `</a>` codes.

Example of translating with html tags in place:

English
```
This poll has closed. <strong>Share the outcome</strong> with the group.
```

Spanish
```
Esta encuesta ha cerrado. <strong>Comparte el resultado</strong> con el grupo.
```

### Interpolation

There are two kinds of interpolation used in our strings:

Example 1

English
```
Started by {{name}}
```

Spanish
```
Iniciado por {{name}}
```

Example 2

English
```
Your request to join %{group_name} has been approved
```

Spanish
```
Tu solicitud para unirte a %{group_name} ha sido aprobada.
```

### Putting it all together - a complex example

English
```
<strong><a href='u/{{username}}'>{{author}}</a></strong> in reply to <strong>{{title}}</strong>
```

Spanish
```
<strong><a href='u/{{username}}'>{{author}}</a></strong> en respuesta a <strong>{{title}}</strong>
```

### Working within a community of translators

As you translate, you might encounter questions like:
- should this use formal/ informal language ?
- who should I check this translation with ? 

In a lot of cases, it's best to work through these challenges with other translators in your language.

Feel free to bring these questions up in the [Loomio Community - Translation](https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation) group.


## Improving processes, giving feedback

If you would like to suggest an improvement, or have some feedback on the translation process, please feel free to start a discussion in the [Loomio Community - Translation](https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation), or email Nati at nati@loomio.org  

**Links** 
- [Loomio Community - Translation](https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation)
- [Loomio on Transifex](https://www.transifex.com/projects/p/loomio-1/)
