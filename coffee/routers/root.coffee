Path = require 'path'
Router = require('express').Router

rootRouter = (config = {}) ->
  router = new Router()
  staticFolderPath = config.staticFolderPath

  getIndex = (request, response) ->
    response.render "index"

  router.get "/", getIndex

  return router

module.exports = rootRouter
