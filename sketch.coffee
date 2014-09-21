When = require 'when'
Keys = require 'when/keys'

a = (locator, callback) ->
  locator.require ["b", "c"], (error, deps) ->
    throw error if error?
    callback null, "A,#{deps.b},#{deps.c}"

b = (locator, callback) ->
  locator.require ["c"], (error, deps) ->
    throw error if error?
    callback null, "B"

c = (locator, callback) ->
  callback null, "C"


class ServiceLocator

  constructor: (props = {}) ->
    @promises = props.promises
    @promises ?= {}

  register: (name, initializeFn) ->
    locator = this
    @promises[name] = When.promise (resolve, reject) ->
      initializeFn locator, (error, resolved) ->
        return reject error if error?
        return resolve resolved

  require: (names = [], callback) ->
    promises = @promises

    process.nextTick ->
      picked = {}
      picked[name] = promises[name] for name in names

      Keys.all(picked)
        .then (required) ->
          callback null, required
        .catch (error) ->
          console.warn "Require #{names} failed."
          console.error error
          throw error
        .done()


locator = new ServiceLocator()

locator.register "a", a
locator.register "b", b
locator.register "c", c

locator.require ["c"], console.log
locator.require ["b"], console.log
locator.require ["a"], console.log

locator.require ["a", "b", "c"], console.log
