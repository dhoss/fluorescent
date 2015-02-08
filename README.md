fluorescent
===========
[![Gem Version](https://badge.fury.io/rb/fluorescent.svg)](http://badge.fury.io/rb/fluorescent) [![Build Status](https://travis-ci.org/dhoss/fluorescent.svg?branch=master)](https://travis-ci.org/dhoss/fluorescent) [![Dependency Status](https://gemnasium.com/dhoss/fluorescent.svg)](https://gemnasium.com/dhoss/fluorescent)[![Code Climate](https://codeclimate.com/github/dhoss/fluorescent/badges/gpa.svg)](https://codeclimate.com/github/dhoss/fluorescent)

# Highlight search terms in a result set and distill the text surrounding the search terms.

Example:

   padding: 10

   search terms: "this is a test"

   search results: "what do you think this is a test"

   padded+highlighted display: "...t do you think **this is a test**..." 


## Basic example:

Here is a search method using [PgSearch](https://github.com/Casecommons/pg_search) to retrieve results in a Rails model:

<script src="https://gist.github.com/dhoss/318097047ffe05eacb55.js"></script>

The Search::Result listing:

<script src="https://gist.github.com/dhoss/24d339d3b7ab43463b62.js"></script>

An example controller:

<script src="https://gist.github.com/dhoss/94ff2c0ac2a9194b8ad1.js"></script>

And an example of how to display the results in a view:

<script src="https://gist.github.com/dhoss/1f7587dbe1ce703585ed.js"></script>

License
=======
The MIT License (MIT)

Copyright (c) 2015 Devin Joel Austin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
