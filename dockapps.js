#!/usr/bin/env node
var Q        = require('q');
var fs       = require('fs');
var path     = require('path');
var spawn    = require('child_process').spawn;
var inquirer = require("inquirer");

var choices  = {
  'Dropbox':   'https://www.dropbox.com/',
  'Facebook':  'https://www.facebook.com/',
  'Flowdock':  'https://www.flowdock.com/app',
  'GitHub':    'https://github.com/',
  'Gmail':     'https://gmail.com/',
  'Instagram': 'http://instagram.com/',
  'Twitter':   'https://twitter.com/',
  'Wikipedia': 'https://en.wikipedia.org/',
  'YouTube':   'https://www.youtube.com/'
};
var choicesKeys = keys(choices);

var templates = [
  'Just open the website',
  'Connect to one existing VPN (PPTP) then open the website'
];

var notExistApps = [];

Q().
then(prompt([{
  type:    'input',
  name:    'installLocation',
  message: 'Install the apps to:',
  default: '/Applications/DockApps/'
}, {
  type:    'confirm',
  name:    'addToDock',
  message: 'Also add the apps to the dock:',
  default: true
}])).
then(function(answers) {
  notExistApps = choicesKeys.filter(function(app) {
    return !fs.existsSync(path.join(answers.installLocation, app + '.app'))
  });
  return answers;
}).
then(prompt({
  type:    'checkbox',
  name:    'apps',
  message: 'Choose your apps:',
  choices: choicesKeys,
  default: function() {
    return notExistApps;
  }
})).
then(function(answers) {
  if (answers.apps.length === 0) {
    return process.exit(0);
  }
  return answers;
}).
then(prompt({
  type:    'confirm',
  name:    'customLinks',
  message: 'Would you like to customize the URLs?',
  default: false
})).
then(function(answers) {
  if (answers.customLinks) {
    var questions = answers.$previous.apps.map(function(favorite) {
      return {
        type:    'input',
        name:    'URL.' + favorite,
        message: 'URL for ' + favorite + ':',
        default: choices[favorite]
      };
    });
    return Q(answers).then(prompt(questions));
  }

  var obj = {};
  obj.$previous = answers;
  obj.$previous.$previous.apps.forEach(function(favorite) {
    obj['URL.' + favorite] = choices[favorite];
  });
  return obj;
}).
then(prompt({
  type:    'confirm',
  name:    'customTemplateEach',
  message: 'Would you like to customize the template for each app?',
  default: false
})).
then(function(answers) {
  if (answers.customTemplateEach) {
    var apps = findKeyInPrevious(answers, 'apps');
    var questions = apps.map(function(favorite) {
      return {
        type:    'list',
        name:    favorite,
        message: 'Choose template for ' + favorite + ':',
        choices: templates
      };
    });
    return Q(answers).then(prompt(questions));
  }

  return Q(answers).then(prompt({
    type:    'list',
    name:    'templateAll',
    message: 'Choose template for all apps:',
    choices: templates
  })).then(function(answers) {
    var value = answers.templateAll;
    delete answers.templateAll;
    findKeyInPrevious(answers, 'apps').map(function(key) {
      answers[key] = value;
    });
    return answers;
  });
}).
then(function(answers) {
  var location  = findKeyInPrevious(answers, 'installLocation');
  var addToDock = findKeyInPrevious(answers, 'addToDock');
  return keys(answers).reduce(function(prev, app) {
    return prev.then(function() {
      process.stdout.write('Processing ' + app + ' ... ');
      var url  = findKeyInPrevious(answers, 'URL.' + app);
      var pptp = templates.indexOf(answers[app]) === 1;
      return dockapps(app, url, location, pptp, addToDock).then(function() {
        console.log('OK');
      }).catch(function() {
        console.log('ERROR');
      });
    });
  }, Q()).then(function() {
    if (addToDock) {
      spawn('killall', [ 'Dock' ]);
    }
  });
});

function dockapps(app, url, location, pptp, addToDock) {
  var args = [
    path.join(__dirname, 'dockapps.sh'),
    '--app',      app,
    '--url',      url,
    '--location', location,
  ];
  if (pptp)      args.push('--pptp');
  if (addToDock) args.push('--dock');
  var deferred = Q.defer();
  var shell    = spawn('bash', args, { cwd: __dirname });
  var stderr   = '';
  shell.stderr.on('data', function(data) {
    stderr += data;
  });
  shell.on('close', function(code) {
    if (code === 0) {
      deferred.resolve();
    } else {
      deferred.reject(stderr.trim());
    }
  });
  return deferred.promise;
}

function keys(object) {
  return Object.keys(object).filter(function(key) {
    return key[0] !== '$';
  });
}

function prompt(questions) {
  return function(previousAnswers) {
    var deferred = Q.defer();
    inquirer.prompt(questions, function(answers) {
      answers.$previous = previousAnswers;
      deferred.resolve(answers);
    });
    return deferred.promise;
  };
}

function findKeyInPrevious(obj, key) {
  var _obj = obj;
  while (_obj) {
    if (_obj.hasOwnProperty(key)) return _obj[key];
    _obj = _obj.$previous;
  }
  return undefined;
}
