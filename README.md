win-elevate
===========

> Execute a Windows command in an elevated command prompt and consume its output in real-time.

[![npm version](https://badge.fury.io/js/win-elevate.svg)](http://badge.fury.io/js/win-elevate)
[![dependencies](https://david-dm.org/jviotti/win-elevate.svg)](https://david-dm.org/jviotti/win-elevate.svg)
[![Build status](https://ci.appveyor.com/api/projects/status/cuoorlv9ag1kadrs/branch/master?svg=true)](https://ci.appveyor.com/project/jviotti/win-elevate/branch/master)

There are many other modules out there to simplify Windows UAC elevation, however none of them take the output of the command they execute and allow the user to consume it a way that is similar to spawning the command with `child_process.spawn()`.

Installation
------------

Install `win-elevate` by running:

```sh
npm install --save win-elevate
```

You can also install globally, which allows you to run `elevate <command>` from the command prompt or from a batch script and have the command output being redirected to `stdout`:

```sh
npm install --global win-elevate
```

Documentation
-------------

### `EventEmitter elevate.run(String[] command)`

The returned `EventEmitter` instance may emit the following events:

- `message (String)`
- `error (Error)`
- `close`

Example:

```js
const elevate = require('win-elevate');

const child = elevate.run([ 'del', 'foo' ]);

child.on('message', function(message) {
  console.log(message);
});

child.on('error', function(error) {
  console.error(error);
  process.exit(1);
});

child.on('close', function() {
  console.log('The command exitted');
});
```

Limitations
-----------

- The `message` event is emitted with output coming from both `stdout` and `stderr`, making it impossible to distinguish the procedence of a message.
- The module doesn't pass the elevated program exit code back to the client.

How it works
------------

The command is executed with `runas`, and its output (both `stdout` and `stderr`) is piped to a temporary file, which is tailed, and piped back to the user.

Support
-------

If you're having any problem, please [raise an issue](https://github.com/jviotti/win-elevate/issues/new) on GitHub and I'll be happy to help.

Tests
-----

Run the test suite by doing:

```sh
npm test
```

Contribute
----------

- Issue Tracker: [github.com/jviotti/win-elevate/issues](https://github.com/jviotti/win-elevate/issues)
- Source Code: [github.com/jviotti/win-elevate](https://github.com/jviotti/win-elevate)

Development
-----------

Run the following command each time you make a change to the `vbs` script:

```sh
npm run rebuild
```

License
-------

The project is licensed under the MIT license.
