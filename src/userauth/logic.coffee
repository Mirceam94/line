fs = require "fs"
spew = require "spew"

setup = (options, imports, register) ->

  snapshot = imports["line-snapshot"]
  authUsers = []

  saved = snapshot.getData "users"

  if saved
    for s in saved
      authUsers.push s
      spew.info "Pushed " + (JSON.stringify s)

  spew.init "Auth ready to go"

  register null,
    "line-userauth":

      checkAuth: (user) ->
        for aU in authUsers
          if user.id == aU.id && user.sess == aU.sess then return true
        false

      authorize: (user) ->
        for aU in authUsers
          if user.id == aU.id && user.sess == aU.sess then return
        authUsers.push user

      deauthorize: (user) ->
        for aU, i in authUsers
          if user.id == aU.id && user.sess == aU.sess
            authUsers.splice i, 1
            return

      getUserList: -> authUsers

module.exports = setup
