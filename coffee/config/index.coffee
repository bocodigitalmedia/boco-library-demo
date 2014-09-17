Path = require 'path'
rootPath = Path.resolve __dirname, "..", ".."

module.exports =
  amqp: require './amqp'
  staticFolderPath: Path.join rootPath, 'public'
  dataFolderPath: Path.join rootPath, 'data'
  uploadsFolderPath: Path.join rootPath, 'uploads'
