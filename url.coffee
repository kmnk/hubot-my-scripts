$ = require('jQuery')

module.exports = (robot) ->
  robot.hear /(https?:\/\/[^<>"{}|\\^\[\]`()]+)/i, (msg) ->
    titleMe msg, msg.match[1], (title) ->
      msg.notice title

titleMe = (msg, url, cb) ->
  msg.http(url)
    .headers
      'Accept-Language': 'ja-JP,ja;q=0.5',
      'Accept-Charset': 'utf-8',
      'User-Agent': "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"
    .get() (err, res, body) ->
      if err
        cb "タイトルを取得できませんでした"
      else
        cb $(body)?.find("title")?.text()
