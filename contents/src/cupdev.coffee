$ = require 'jquery-browserify'
_ = require 'underscore'

P = (a...) ->
  console.log a...
  return _.last a

$(document).ready ->
  _.map ($ '.date'), (e__) ->
    e = $ e__
    ds = e.html()
    e.html (new Date e.html())
      .toLocaleString()
    P ds, " => ", e.html()

  