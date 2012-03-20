_ = require('underscore')
_.str = require('underscore.string')

tmpSnap = {}

module.exports = (robot) ->
  unless robot.brain.data.snap
    robot.brain.data.snap = {}

  robot.hear /(.+)/, (msg) ->
    snapTmp msg

  robot.respond /snap(?: (.+))?$/i, (msg) ->
    snap msg, msg.match?[1], (res) ->
      msg.notice res

  robot.respond /show snap(?: (\d{1}))?$/i, (msg) ->
    showSnap msg, msg.match?[1], (res) ->
      msg.notice res

  robot.respond /show snaps$/i, (msg) ->
    showSnaps msg, (res) ->
      msg.send res

  robot.respond /reset snap$/i, (msg) ->
    resetSnaps msg, (res) ->
      msg.notice res

  robot.respond /reset snap all$/i, (msg) ->
    resetAllSnaps msg, (res) ->
      msg.notice res

snapTmp = (msg) ->
  if _isCommand msg then return

  data = _format msg
  tmpSnap[data.room] = data.val
  tmpSnap[data.key]  = data.val
  console.log tmpSnap

snap = (msg, name, cb) ->
  data = _format msg, name
  if name
    val = tmpSnap[data.key]
  else
    val = tmpSnap[data.room]

  res = _add msg, data.room, val
  if res
    cb "snap '#{val}'"
  else
    cb "cannot snap"

showSnap = (msg, index, cb) ->
  data = _format msg
  list = _getList msg, data.room
  index = index ? 0
  val = list?[index]?

  if val
    cb list[index]
  else
    cb "cannot get snap data"

showSnaps = (msg, cb) ->
  data = _format msg
  list = _getList msg, data.room

  if list && list.length > 0
    cb list.join "\n"
  else
    cb "cannot get snap data"

resetSnaps = (msg, cb) ->
  data = _format msg
  _reset msg, data.room
  cb "reset"

resetAllSnaps = (msg, cb) ->
  data = _format msg
  _resetAll msg
  cb "reset all"

_isCommand = (msg) ->
  robot = msg.robot
  if robot.alias
    alias = robot.alias.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") # escape alias for regexp
    newRegex = new RegExp("^(?:#{alias}[:,]?|#{@name}[:,]?)\\s*(?:#{pattern})", modifiers)
  else
    newRegex = new RegExp("^#{@name}[:,]?\\s*(?:#{pattern})", modifiers)

  msg.message.text.match(newRegex)

_time = () ->
  date = new Date
  _.str.sprintf '%04s/%02s/%02s %02s:%02s:%02s',
    date.getYear() + 1900,
    date.getMonth(),
    date.getDate(),
    date.getHours(),
    date.getMinutes(),
    date.getSeconds()

_format = (msg, name) ->
  time = _time()
  user = msg.message.user
  room = user.room ? "UNKNOWN"
  name = name ? user.name ? "UNKNOWN"
  text = msg.message.text
  return {
    room: room,
    name: name,
    key:  "#{room}:#{name}"
    val:  "[#{time}] (#{name}) #{text}"
  }

_add = (msg, room, val) ->
  unless msg.robot.brain.data.snap?[room]
    msg.robot.brain.data.snap?[room] = []

  snaps = msg.robot.brain.data.snap[room]

  snaps = [val].concat snaps

  if snaps.length > 10
    snaps = _.initial snaps

  msg.robot.brain.data.snap[room] = snaps
  msg.robot.brain.save()

_getList = (msg, room) ->
  console.log msg.robot.brain.data.snap
  unless msg.robot.brain.data.snap?[room]
    return ["no data"]
  else
    return msg.robot.brain.data.snap[room]

_reset = (msg, room) ->
  msg.robot.brain.data.snap?[room] = []

_resetAll = (msg) ->
  msg.robot.brain.data.snap = {}
