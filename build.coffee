{Serenade} = require './src/serenade'

CoffeeScript = require 'coffee-script'
fs = require 'fs'
path = require 'path'
gzip = require 'gzip'

header = """
  /**
   * Serenade.js JavaScript Framework v#{Serenade.VERSION}
   * http://github.com/elabs/serenade.js
   *
   * Copyright 2011, Jonas Nicklas, Elabs AB
   * Released under the MIT License
   */
"""

Build =
  files: ->
    files = {}
    sourceFiles = fs.readdirSync 'src'
    for name in sourceFiles when name.match(/\.coffee$/)
      content = fs.readFileSync('src/' + name).toString()
      files[name.replace(/\.coffee$/, "")] = CoffeeScript.compile(content, bare: false)
    files["parser"] = Build.parser()
    files

  parser: -> require('./src/grammar').Parser.generate()

  compile: (callback) ->
    files = Build.files()
    requires = ''
    for name in ['events', 'helpers', 'cache', 'collection', 'association_collection', 'properties', 'model', 'serenade', 'lexer', 'node', 'dynamic_node', 'compile', 'parser', 'view']
      requires += """
        require['./#{name}'] = new function() {
          var exports = this;
          #{files[name]}
        };
      """
    callback """
      (function() {
        var root = this;
        var Serenade = function() {
          function require(path){ return require[path]; }
          #{requires}
          return require['./serenade'].Serenade
        }();

        if(typeof define === 'function' && define.amd) {
          define(function() { return Serenade });
        } else if (typeof exports !== 'undefined') {
          if (typeof module !== 'undefined' && module.exports) {
            exports = module.exports = Serenade;
          }
          exports.Serenade = Serenade;
        } else { root.Serenade = Serenade }
      }());
    """.replace(/require/g, 'localRequire')

  unpacked: (callback) ->
    Build.compile (code) -> callback(header + '\n' + code)

  minified: (callback) ->
    Build.compile (code) ->
      {parser, uglify} = require 'uglify-js'
      minified = uglify.gen_code uglify.ast_squeeze uglify.ast_mangle parser.parse code
      callback(header + "\n" + minified)

  gzipped: (callback) ->
    Build.minified (minified) ->
      gzip (minified), (err, data) ->
        callback(data)

exports.Build = Build
