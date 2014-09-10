Router = require('express').Router

module.exports = (config = {}) ->
  router = new Router()
  resolveStaticPath = config.resolveStaticPath

  getIndex = (request, response) ->
    path = resolveStaticPath "index.html"
    response.sendFile path

  router.get "/", getIndex

  return router
