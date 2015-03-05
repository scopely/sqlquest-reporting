Sync = require 'sync'
AWS = require 'aws-sdk'
_ = require 'lodash'
ent = require 'ent'
moment = require 'moment'
HtmlBuilder = require '../htmlbuilder'

module.exports = (quest, opts) ->

  buildText = (message) ->
    if _.isString message
      message
    else
      strings = message.map (blob) ->
        if _.isString blob
          blob
        else
          quest.table blob, print: false
      strings.join('\n\n')

  buildHtml = (f) ->
    f(new HtmlBuilder)

  ses = new AWS.SES region: opts.region ? 'us-east-1'

  body = {}

  if opts.message
    body =
      Text:
        Data: buildText(opts.message)

  if opts.html?
    body.Html =
      Data: buildHtml(opts.html)

  ses.sendEmail.sync ses,
    Source: opts.from
    Destination:
      BccAddresses: opts.bcc or []
      CcAddresses: opts.cc or []
      ToAddresses: opts.to
    Message:
      Subject:
        Data: opts.subject
      Body: body
