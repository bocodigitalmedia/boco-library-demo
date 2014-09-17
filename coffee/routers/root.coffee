Path = require 'path'
Router = require('express').Router

rootRouter = (config = {}) ->
  router = new Router()
  staticFolderPath = config.staticFolderPath

  getIndex = (request, response) ->
    path = Path.join staticFolderPath, "index.html"
    response.sendFile path

  router.get "/", getIndex

  return router

module.exports = rootRouter
