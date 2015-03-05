# Public: Reporting helper.
#
# Requires the reporter for the specified type and executes it with the quest
# object itself and your options.
#
# * `type`: {String} Reporter to use. `ses`, for example.
# * `options`: {Object} options to pass to the reporter.
report = (type, options) ->
  console.log "Building #{type} report...".blue
  require("./reporters/#{type}")(@, options)

# Plugin harness.
module.exports = (q) ->
  q.addHelper 'report', report
