/*
 * The MIT License
 *
 * Copyright (c) 2016 Juan Cruz Viotti. https://github.com/jviotti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

const path = require('path');
const fs = require('fs');

const ARG_INPUT = process.argv[2];
const ARG_OUTPUT = process.argv[3];

if (!ARG_INPUT || !ARG_OUTPUT) {
  console.error('Usage: ' + process.argv[1] + ' <input> <output>');
  process.exit(1);
}

const currentWorkingDirectory = process.cwd();
const VBS = path.join(currentWorkingDirectory, ARG_INPUT);
const BAT = path.join(currentWorkingDirectory, ARG_OUTPUT);
const scriptContents = fs.readFileSync(VBS, {
  encoding: 'utf8'
});

const polyglotHeader = [
  '<!-- : Begin batch script',
  '@echo off',
  'cscript //nologo "%~f0?.wsf" %*',
  'exit /b',
  '',
  '----- Begin wsf script --->',
  '<job><script language="VBScript">'
].join('\n');

const polyglotFooter = [
  '</script></job>'
].join('\n');

fs.writeFileSync(BAT, polyglotHeader + scriptContents + polyglotFooter);
