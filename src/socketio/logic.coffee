spew = require "spew"

setup = (options, imports, register) ->

  server = imports.server
  ioObject = null # Initialized in init();
  listeners = []

  addListener = (listener, socket) ->
    socket.on listener.name, (data) ->
      listener.cb data, socket

  spew.init "Sockets init done, awaiting end of global init"

  register null,
    "line-socketio":

      io: -> ioObject

      # Set socket log level
      #
      # Args:
      #  l  - Log level [default is 1]
      updateLogLevel: (l) ->
        if l != this.logLevel
          this.logLevel = l
          ioObject.set "log level", l

      logLevel: 1

      # Used at init
      secure: false
      key: null
      cert: null
      ca: null

      # Socket IO Init
      #
      # Args:
      #  s  - HTTP Server
      #
      init: (s) ->
        if this.secure && this.key && this.cert && this.ca
          spew.info "Starting secure socket io"

          ioObject = require("socket.io").listen s.httpServer(),
            key: this.key
            cert: this.cert
            ca: this.ca

          spew.init "Started socket io with SSL support"
        else
          if this.secure
            spew.warning "No key/cert/ca provided, starting in unsecure mode!"

          ioObject = require("socket.io").listen s.httpServer()
          spew.init "Started socket io"

        ioObject.set "log level", this.logLevel
        ioObject.enable "browser client minification"
        ioObject.enable "browser client etag"
        ioObject.enable "browser client gzip"

      addListener: (name, cb) ->
        spew.info "Added socket listener [#{name}]"
        listeners.push
          "name": name
          "cb": cb

      initListeners: ->
        ioObject.sockets.on "connection", (socket) ->
          for listener in listeners
            addListener listener, socket

      # Retrieve data stored on socket, standardized error messages
      #
      # Args:
      #  sock - Socket to query
      #  names - Name of single value, or an array of names
      #  cb   - Function to call with data
      #
      getData: (sock, names, cb, errcb) ->

        if Object.prototype.toString.call(names) != "[object Array]"
          names = [ names ] # Single value

        fetching = names.length
        fetched = []

        for name in names
          sock.get name, (err, data) ->
            if err
              spew.error "Failed to query socket [#{err}]"
              if errcb then errcb err
            else

              fetched.push data
              fetching--

              if fetching == 0
                if fetched.length == 1 then fetched = fetched[0]
                cb fetched

module.exports = setup
