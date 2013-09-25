fs = require "fs"
mongoose = require "mongoose"
spew = require "spew"

setup = (options, imports, register) ->

  connected = false
  objects = null
  connectedDB = ""

  register null,
    "line-mongodb":

      # Sets up DB models for this instance
      #
      # Args:
      #  index    - Path to module exporting models
      setupModels: (index) ->
        if connectedDB != ""
          spew.warning "Database already set up!"
          return

        objects = require index

        for key of objects
          objects[key].createSchema()
          objects[key].createModel()

        spew.init "Database models loaded from " + index

      # Connect to Database
      #
      # Args:
      #  user  - Username for DB
      #  pass  - Password for username
      #  host  - DB Host
      #  port  - Port to access DB on
      #  db    - Database to connect too
      #
      connect: (user, pass, host, port, db) ->
        if not connected and objects

          con = "mongodb://#{user}:#{pass}@#{host}:#{port}/#{db}"

          mongoose.connect con, (err) ->
            if err then spew.critical "Error connecting to database [#{err}]"
            else
              spew.init "Connected to MongoDB database"
              connected = true
              connectedDB = db

        else if objects
          spew.error "You need to setup your models before connecting!"
        else spew.warning "Already connected to db #{connectedDB}!"

      # Returns DB objects
      #
      models: -> objects

      # Performs DB fetch, single or multiple queries
      #
      # Args:
      #  models  - Single, or list of model names to query
      #  queries - Single, or list of queries
      #  cb    - Callback to deliver results too
      #  errcb - Callback to call in case of an error
      #  wide  - If true, result is always an array
      #
      fetch: (models, queries, cb, errcb, wide) ->

        if not wide then wide = false

        # Check if single model has been passed in
        if Object.prototype.toString.call(models) != "[object Array]"
          models = [ models ]

          # Reformat queries if necessary
          if Object.prototype.toString.call(queries) != "[object Array]"
            queries = [ queries ]
        else

          if queries.length != models.length
            spew.critical "Called db fetch without enough queries!"
            throw "DB Query count != model count"

        fetching = models.length
        fetched = []

        for m, i in models
          do (m, i) ->
            objects[m].getModel().find queries[i], (err, data) ->

              ret = undefined

              if err
                spew.error "DB Error: #{err}"
                if errcb then errcb err
              else ret = data

              # Emulates findOne()
              if ret != undefined
                if ret.length == 1 and not wide then ret = ret[0]

              fetched[i] = ret #Ensure correct return order
              fetching--

              if fetching == 0
                # Emulates findOne()
                if fetched.length == 1 then fetched = fetched[0]

                cb fetched

module.exports = setup
