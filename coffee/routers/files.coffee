Path = require 'path'
Express = require 'express'
BusBoy = require 'connect-busboy'
FileSystem = require 'fs'

filesRouter = (config = {}) ->
  uploadsFolderPath = config.uploadsFolderPath
  busboy = BusBoy()
  router = Express()

  uploadFile = (request, response) ->
    baseUrl = request.baseUrl

    request.busboy.on 'file', (fieldName, uploadStream, fileName, encoding, mimeType) ->
      uploadPath = Path.join uploadsFolderPath, fileName
      writeStream = FileSystem.createWriteStream uploadPath
      uploadStream.pipe writeStream

      writeStream.on 'close', ->
        response.redirect baseUrl

      writeStream.on 'error', (error) ->
        response.status(500).send "Internal Server Error"

    request.pipe request.busboy

  showIndex = (request, response) ->
    baseUrl = request.baseUrl

    FileSystem.readdir uploadsFolderPath, (error, files) ->
      throw error if error?
      response.status 200
      response.write "<!doctype html>"
      response.write "<html>"
      response.write "<head><title>Files</title></head>"
      response.write "<body>"
      response.write "<h1>Files</h1>"
      response.write "<ul>"
      response.write "<li><a href=\"#{baseUrl}/#{path}\">#{path}</a></li>" for path in files
      response.write "</ul>"
      response.write "<form action=\"#{baseUrl}\" method=\"post\" enctype=\"multipart/form-data\">"
      response.write '<input type="file" name="file" />'
      response.write '<input type="submit" />'
      response.write '</form>'
      response.write "</body>"
      response.write "</html>"
      response.end()

  getFile = (request, response) ->
    fileName = request.params.fileName
    path = Path.join uploadsFolderPath, fileName

    FileSystem.exists path, (isPresent) ->
      return response.status(404).send "Not Found" unless isPresent
      return response.sendFile path

  router.post "/", busboy, uploadFile
  router.get "/", showIndex
  router.get "/:fileName", getFile

  return router

module.exports = filesRouter
