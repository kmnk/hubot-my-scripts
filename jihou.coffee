cron = require('cron').CronJob

module.exports = (robot) ->
    robot.respond /jihou/i,  (msg) -> jihou(msg)
    robot.respond /jiho-/i,  (msg) -> jihou(msg)
    robot.respond /時報/i,   (msg) -> jihou(msg)
    robot.respond /じほう/i, (msg) -> jihou(msg)
    robot.respond /じほー/i, (msg) -> jihou(msg)

    jihou = (msg) ->
        date = new Date
        hour = date.getHours()
        min  = date.getMinutes()
        sec  = date.getSeconds()
        msg.notice "#{hour}時#{min}分#{sec}秒 です！"

    # utility function
    notice = (room, msg) ->
        res = new robot.Response(robot, {user : {id : -1, name : room}, text : "none", done : false}, [])
        res.notice msg

    cron '00 00 * * * *', () ->
        date = new Date
        hour = date.getHours()
        notice "#暇人集会@friend", "#{hour}時ですよー"
