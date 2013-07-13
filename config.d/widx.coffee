_  = require 'underscore'
_s = require 'underscore.string'

P = (a...) ->
  console.log a...
  a[0]

rev = (ar) ->
  _.times ar.length, (i) ->
    ar[ar.length - 1 - i]

embed = (cnt) ->
  x= _.values cnt
  x= _.sortBy x, (art) -> art.date
  x= rev x

wordlist = (x) ->
  x= _s.words x, /,/
  x= _.map x, (x) -> _s.strip x
  x= _.filter x, (s) -> s

treesec = (x) ->
  x= _s.words x, /\//
  x= _.map x, (x) -> _s.strip x
  x= _.filter x, (s)->s
  x= _.times x.length, (i) ->
    name: x[i]
    path: _s.join "/", x[..i]
    depth: i

exports._ = _
exports._s = _s
exports.embed = embed
exports.wordlist = wordlist
exports.treesec = treesec
exports.rev = rev
