_ = require('underscore')
_.str = require('underscore.string')

format = '%s,%s'

module.exports = (robot) ->
  unless robot.brain.data.incrdecr
    robot.brain.data.incrdecr = {}

  robot.hear /^(.+)[+]{2}$/i, (msg) ->
    incr msg, msg.match[1], (res) ->
      msg.notice res

  robot.hear /^(.+)[-]{2}$/i, (msg) ->
    decr msg, msg.match[1], (res) ->
      msg.notice res

  robot.respond /count\? (.+)$/i, (msg) ->
    countDefault msg, msg.match[1], (res) ->
      msg.notice res

  robot.respond /count details\? (.+)$/i, (msg) ->
    countDetails msg, msg.match[1], (res) ->
      msg.notice res

  robot.respond /reset (.+) incrdecr$/i, (msg) ->
    resetCount msg, msg.match[1], (res) ->
      msg.notice res

incr = (msg, name, cb) ->
  data = _get msg, name
  data.plus++
  _set msg, name, data
  countDefault msg, name, cb

decr = (msg, name, cb) ->
  data = _get msg, name
  data.minus++
  _set msg, name, data
  countDefault msg, name, cb

countDefault = (msg, name, cb) ->
  data = _get msg, name
  cb _.str.sprintf "#{name}: %s", data.plus - data.minus

countDetails = (msg, name, cb) ->
  data = _get msg, name
  cb _.str.sprintf "#{name}:{ +:%s, -:%s }", data.plus ,data.minus

resetCount = (msg, name, cb) ->
  _resetCount msg, name
  cb "reset #{name} count"

_get = (msg, name) ->
  unless msg.robot.brain.data.incrdecr?[name]
    _resetCount msg, name

  [plus, minus] = msg.robot.brain.data.incrdecr?[name].split(',')

  return plus: plus, minus: minus

_set = (msg, name, data) ->
  msg.robot.brain.data.incrdecr?[name] = _.str.sprintf format, data.plus, data.minus
  msg.robot.brain.save()

_resetCount = (msg, name) ->
  msg.robot.brain.data.incrdecr?[name] = _.str.sprintf format, 0, 0
