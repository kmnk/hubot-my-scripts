_ = require('underscore')
_.str = require('underscore.string')

amazon_tag = 'onawhim06-22'
engine =
  alc:
    name: '英辞郎 on the WEB'
    default: false
    uri: 'http://eow.alc.co.jp'
    path: '/search'
    keywordQueryKey: 'q'
  oreillyjapan:
    name: "O'Reilly Japan"
    default: false
    uri: 'http://www.oreilly.co.jp'
    path: '/app/search'
    keywordQueryKey: 'q'
  oreilly:
    name: "O'Reilly"
    default: false
    uri: 'http://search.oreilly.com'
    path: '/'
    keywordQueryKey: 'q'
  google:
    name: 'Google'
    default: true
    uri:  'https://www.google.co.jp'
    path: '/search'
    query:
      ie: 'utf-8'
      oe: 'utf-8'
      hl: 'ja'
    keywordQueryKey: 'q'
  amazon:
    name: 'Amazon.co.jp'
    default: true
    uri:  'http://www.amazon.co.jp'
    path: '/mn/search'
    query:
      _encoding: 'UTF8'
      tag: amazon_tag
      linkCode: 'url2'
    keywordQueryKey: 'field-keywords'
  wikipedia:
    name: 'Wikipedia'
    default: true
    uri:  'http://ja.wikipedia.org'
    path: '/wiki/'
    keywordQueryKey: false
  uncyclopedia:
    name: 'アンサイクロペディア'
    default: true
    uri:  'http://ja.uncyclopedia.info'
    path: '/wiki/'
    keywordQueryKey: false

module.exports = (robot) ->
  robot.respond /search-engines?\?$/i, (msg) ->
    engineKeys = _.map engine, (v, k) -> k
    msg.notice engineKeys.join ', '

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
      unless data.default then continue
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
