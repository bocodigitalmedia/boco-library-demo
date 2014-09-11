Router = require('express').Router

rootRouter = (config = {}) ->
  router = new Router()
  resolveStaticPath = config.resolveStaticPath

  getIndex = (request, response) ->
    path = resolveStaticPath "index.html"
    response.sendFile path

  router.get "/", getIndex

  return router

module.exports = rootRouter
