### Loomio Development Quickstart

1. Clone the Loomio repo from github
```
git clone git@github.com:loomio/loomio.git && cd loomio
```

If you're on OSX then you can run the following bootstrap task to setup your system with postgresql, npm, bundler and gulp. It will then create an admin user. If you need help installing ruby, or more detail on installing the dependencies, please read [Setup Environment](setup_environment.md)

2. Run the bootstrap task
```
rake bootstrap
```

_NB: Take note of the email and password generated at the end of this task; you'll need it to log in once setup is complete_

3. Build the angular frontend
```
cd angular && gulp compile
```
4. Launch the server
```
rails s
```

##### Other things to know
- There are several other gulp commands you can run to make your development go. These can be run from the `angular` folder.
  - `gulp dev`: Automatically rebuild the javascript app as you make changes
  - `gulp protractor`: Run the automated frontend tests
  - `gulp protractor:now`: Rebuild the javascript app, then run the automated frontend tests
  - `PRIVATE_PUB_SECRET_TOKEN=abc123 bundle exec rackup private_pub.ru -E production` is how your start faye in development

##### Having trouble?

- Make sure ruby (2.3.0), node (4.2.6; not 5+!), postgres (9.4+), and [ImageMagick](http://stackoverflow.com/questions/3704919/installing-rmagick-on-ubuntu) are installed
- Let us know in the [product team](https://www.loomio.org/g/VmBUX7WM/loomio-community-product-team) group on Loomio.
