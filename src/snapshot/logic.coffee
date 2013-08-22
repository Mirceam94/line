spew = require "spew"
fs = require "fs"

setup = (options, imports, register) ->

  snapshot = { }
  snapshotDir = ""

  spew.init "Snapshot ready to go"

  register null,
    "line-snapshot":
      setup: (path) ->
        snapshotDir = path
        if fs.existsSync(path)
          spew.info "Snapshot found, proceeding"

          data = fs.readFileSync path

          if data.length == 0
            spew.warning "No data in snapshot, continuing"
          else
            snapshot = JSON.parse data
      getData: (name) ->
        snapshot[name]
      addData: (name, d) ->
        snapshot[name] = d
      save: ->
        if snapshotDir.length > 0
          fs.writeFileSync snapshotDir, JSON.stringify(snapshot)
        else
          spew.warning "No snapshot path provided"

module.exports = setup
