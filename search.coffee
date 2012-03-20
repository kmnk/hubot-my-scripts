_ = require('underscore')
_.str = require('underscore.string')

amazon_tag = 'onawhim06-22'
engine =
  google:
    name: 'Google'
    uri:  'https://www.google.co.jp'
    path: '/search'
    query:
      ie: 'utf-8'
      oe: 'utf-8'
      hl: 'ja'
    keywordQueryKey: 'q'
  amazon:
    name: 'Amazon.co.jp'
    uri:  'http://www.amazon.co.jp'
    path: '/mn/search'
    query:
      _encoding: 'UTF8'
      tag: amazon_tag
      linkCode: 'url2'
    keywordQueryKey: 'field-keywords'
  wikipedia:
    name: 'Wikipedia'
    uri:  'http://ja.wikipedia.org'
    path: '/wiki/'
    keywordQueryKey: false
  uncyclopedia:
    name: 'アンサイクロペディア'
    uri:  'http://ja.uncyclopedia.info'
    path: '/wiki/'
    keywordQueryKey: false

module.exports = (robot) ->
  robot.respond /(?:(.+) )?search (.+)$/i, (msg) ->
    searchMe msg, msg.match[1], msg.match[2], (res) ->
      msg.notice res

  robot.respond /(?:(.+)で)?探(?:して)? (.+)$/i, (msg) ->
    searchMe msg, msg.match[1], msg.match[2], (res) ->
      msg.notice res

  robot.respond /(?:(.+)で)?さがして (.+)$/i, (msg) ->
    searchMe msg, msg.match[1], msg.match[2], (res) ->
      msg.notice res

  robot.respond /(?:(.+)で)?(?:検索)(?:して)? (.+)$/i, (msg) ->
    searchMe msg, msg.match[1], msg.match[2], (res) ->
      msg.notice res

  robot.respond /(?:(.+)で)?(?:けんさく)(?:して)? (.+)$/i, (msg) ->
    searchMe msg, msg.match[1], msg.match[2], (res) ->
      msg.notice res

searchMe = (msg, engineName, keywords, cb) ->
  encodedKeywords = encodeURIComponent keywords

  if engineName
    unless _.has engine, engineName.toLowerCase()
      return cb "cannnot search on #{engineName}"
    res = _build engine[engineName.toLowerCase()], encodedKeywords
    if res then cb res
  else
    for key, data of engine
      res = _build data, encodedKeywords
      if res then cb res

_build = (data, keywords) ->
  queries = []

  url = "#{data.uri}#{data.path}"

  if data.query
    queries = _.map data.query, (queryVal, queryKey) ->
      "#{queryKey}=#{queryVal}"

  if data.keywordQueryKey
    queries[queries.length] = "#{data.keywordQueryKey}=#{keywords}"

  unless data.keywordQueryKey
    url += keywords

  if queries and queries.length > 0
    url += '?' + queries.join '&'

  if url and url.length > 0
    return "[#{data.name}] #{url}"
  else
    return false
