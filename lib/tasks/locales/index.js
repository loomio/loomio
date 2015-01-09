var http = require('http');
var Url = require('url');
var request = require('request');
var fs = require('fs');
var flatten = require('flat');
var yaml = require('js-yaml');
var indent = require('indent-string');

var projectSlug = 'loomio-1'

function getFromTransifex(path) {

  var login = {
    username: process.env.TRANSIFEX_USERNAME,
    password: process.env.TRANSIFEX_PASSWORD,
  }

  return function(callback) {
    request({
      method: "get",
      url: Url.format({
        protocol: "http",
        hostname: "www.transifex.com",
        pathname: path,
      }),
      auth: login,
    }, callback);
  };
};

var getLanguageInfo = getFromTransifex('/api/2/project/loomio-1/languages')

getLanguageInfo( function(err, res, body) {
  if (err) { throw err; }
  
  var transifexLocales = JSON.parse(body).map( function(a) { return a['language_code'] })
  console.log(" Got locale list\n")
  updateLocales(transifexLocales)
})

function updateLocales(locales) {
  var resources = [
    {
     transifexSlug: 'github-linked-version',
     localFilePrefix: '',
    },
    {
     transifexSlug: 'frontpageenyml',
     localFilePrefix: 'frontpage.',
    },
  ]

  resources.forEach( function(resource) {
    locales.forEach( function(locale) {
      getFromTransifex("/api/2/project/"+projectSlug+"/resource/"+resource.transifexSlug+"/translation/"+locale)(updateLocale(resource, locale))
    })
  })
}

function updateLocale(resource, locale) {
  return function(err, res, body) {
    if (err) { throw err; }
    
    var localesDir = 'config/locales/'
    var correctedLocale = locale.replace('_','-')
    var filename = localesDir + resource.localFilePrefix + correctedLocale + '.yml'
    var refFile = localesDir + resource.localFilePrefix + 'en.yml'

    // get and correct the transifex translation
    var tempTransifexTranslations = yaml.safeLoad(JSON.parse(body).content)
    var transifexTranslations = {}
    transifexTranslations[correctedLocale] = tempTransifexTranslations[locale]
    
    // load loomio translation and compare
    fs.readFile(refFile, function(err, data) {
      if (err) { throw err; }

      var flatRefTranslations = flatten(yaml.safeLoad(data))
      var flatTransifexTranslations = flatten(transifexTranslations)
     
      Object.keys(flatRefTranslations).forEach( function(key) {
        var localeKey = key.replace('en.', correctedLocale+'.')

        var value = flatRefTranslations[key]
        var localeValue = flatTransifexTranslations[localeKey]

        if (typeof(localeValue) === 'undefined') {return}

        var args = { locale: locale, resource: resource, key: key, value: value, localeKey: localeKey, localeValue: localeValue }
        checkInterpolation(args)
        checkHTML(args)
      })
    })

    fs.writeFile(filename, yaml.safeDump(transifexTranslations), function(err) {
      if (err) { throw err; }

      //process.stdout.write(green(locale)+' ')
      process.stdout.write(green('.'))
    })

  }
}

function checkInterpolation(args) {
  var locale= args.locale, resource= args.resource, key= args.key, value= args.value, localeKey= args.localeKey, localeValue= args.localeValue;
  
  var regex = /%{[^{}]*}/gm
  var skipKeys = ["en.invitation.invitees_placeholder",]

  var match = value.match(regex)
  var localeMatch = localeValue.match(regex)

  if (match === null) {return}
  if (localeMatch === null) {throw localeKey}

  //note we interpolation keys are not order dependent, so we normalise by .sort()'ing
  if ( (match.sort().join(':') !== localeMatch.sort().join(':'))
    && (skipKeys.indexOf(key) === -1) ){
      niceLog( {locale: locale, key: key, value: value, localeKey: localeKey, localeValue: localeValue, resource: resource, regex: regex} )
  }
}

function checkHTML(args) {
  var locale= args.locale, resource= args.resource, key= args.key, value= args.value, localeKey= args.localeKey, localeValue= args.localeValue;
  
  var regex = /\<[^\<\>]*\>/gm
  var skipKeys = ["en.invitation.invitees_placeholder",]

  var match = value.match(regex)
  var localeMatch = localeValue.match(regex)

  if (match === null) {return}
  if (localeMatch === null) {throw localeKey}

  //note we don't sort keys because html is order dep. this could be trickier with some languages
  if ( (match.join(':') !== localeMatch.join(':'))
    && (skipKeys.indexOf(key) === -1) ){
      niceLog( {locale: locale, key: key, value: value, localeKey: localeKey, localeValue: localeValue, resource: resource, regex: regex} )
  }
}

function niceLog(args) {
  var locale= args.locale, key= args.key, value= args.value, localeKey= args.localeKey, localeValue= args.localeValue, resource= args.resource, regex= args.regex;
  var correctedLocale = locale.replace('_','-')

  console.log( indent(red(localeKey) + " : " + blue("https://www.transifex.com/projects/p/" +projectSlug+ "/translate/#" +locale+ "/" +resource.transifexSlug+ "/?key=" +key.substr(3)),  ' ', 2) )
  process.stdout.write( indent(bold("["+correctedLocale+"]"), ' ', 4) )
  console.log( indent(localeValue, ' ', 2).replace(regex,green) )
  process.stdout.write( indent("[en]", ' ', 4) )
  console.log( indent(value, ' ', 2).replace(regex,green) )
  console.log('')
}

function green(string) { return ("\033[32m"+ string +"\033[0m") }
function red(string) { return ("\033[31m"+ string +"\033[0m") }
function blue(string) { return ("\033[36m"+ string +"\033[0m") }
function bold(string) { return ("\033[101m"+ string +"\033[0m") }
 
