_ = require 'lodash'
ent = require 'ent'
moment = require 'moment'

module.exports =

# Public: HTML email builder class.
#
# A convenience class for building HTML emails with embedded styling and such
# Because it's a real pain in the ass.
class HtmlBuilder

  # Public: Initialize the HTML builder with an empty body.
  constructor: ->
    @body = ""

  # Public: Append raw HTML to our body.
  #
  # This method performs no escaping or magic. It literally just appends the
  # string you pass to `@body` with a newline.
  #
  # * `s`: {String} HTML to append.
  rawHtml: (s) ->
    @body += "#{s}\n"

  # Public: Object -> style attribute string.
  #
  # Convenience function for creating a style attribute to embed in a tag.
  #
  # * `obj`: {Object} Object with keys being style names.
  #
  # Returns a {String} with our style attribute.
  style: (obj) ->
    style = ""
    for k, v of obj
      style += "#{k}:#{v};" if v.trim()
    "style=\"#{style}\""

  # Public: Shortcut to ent for HTML entity encoding.
  ent: ent.encode

  # Public: Append a paragraph to our email.
  #
  # Note that this method appends directly and thus will not return a paragraph
  # tag string.
  #
  # * `s`: {String} Paragraph text.
  # * `opts`: {Object} Options
  #   * `italic`: {Boolean}
  #   * `bold`: {Boolean}
  paragraph: (s, opts={}) ->
    pStyle = {}
    pStyle['font-style'] = 'italic' if opts.italic
    pStyle['font-weight'] = 'bold' if opts.bold

    @rawHtml "<p #{@style pStyle if pStyle}>#{s}</p>"

  # Public: Create a hyperlink.
  #
  # * `url`: {String} URL to link to.
  # * `text`: {String} link text. Defaults to `url`.
  #
  # Returns a {String} representation of an anchor tag.
  link: (url, text=url) ->
    text = ent.encode text
    "<a href=\"#{url}\">#{text}</a>"

  # Public: Append a header tag of varying sizes to the HTML body.
  #
  # * `s`: {String} Header text.
  # * `size`: {String} Size of header. Options are `"small"`, `"medium"`, and
  #           `"large"` and they correspond to h3, h2, and h1 respectively.
  header: (s, size="medium") ->
    sizes =
      small:  'h3'
      medium: 'h2'
      large:  'h1'

    tag = sizes[size]
    @rawHtml "<#{tag}>#{s}</#{tag}>"

  # Public: Create an HTML table with results of a `@sql` call.
  #
  # A configurable "usually-does-the-right-thing" table generator. It appends
  # directly to `@body`.
  #
  # * `results`: Results of a `@sql` call.
  # * `opts`: {Object} Options to change the table's behavior.
  #   * `trimWhitespace`: {Boolean} If false, don't trim extra whitespace from
  #     varchar columns.
  #   * `encodeEntities`: {Boolean} If false, don't encode HTML entities.
  #   * `maxWidth`: {String} table max width. Defaults to 1000px, but some email
  #     clients do not pay attention to this style.
  #   * `minWidth`: {String} table min width. Defaults to 650px, but some email
  #     clients don't pay attention to this.
  #   * `wrap`: {Array} of column names we'd like to let text wrap in. By
  #     default wrapping is turned off for all columns because often this looks
  #     better.
  table: (results, opts={}) ->
    opts.trimWhitespace ?= true
    opts.encodeEntities ?= true
    opts.maxWidth ?= '1000px'
    opts.minWidth ?= '650px'
    opts.wrap ?= []

    wrap = (column, style) =>
      if _.includes opts.wrap, column
        @style _.omit(style, 'white-space')
      else
        @style style

    if results.rows.length > 0
      borderStyle =
        padding: '5px'
        border: '1px solid black'
        'white-space': 'nowrap'

      columns = (field.name for field in results.fields)
      headerCells = for column in columns
        "<th #{wrap column, borderStyle}>#{column}</th>"

      rows = for row in results.rows
        cells = for column in columns
          value = row[column]
          value = value.trim() if opts.trimWhitespace and _.isString(value)
          value = ent.encode(value) if opts.encodeEntities and _.isString(value)
          value = moment(value).format('YYYY-MM-DD HH:mm:ss') if _.isDate(value)
          """<td #{wrap column, borderStyle}>
                #{value}
             </td>"""
        "<tr>#{cells.join('\n')}</tr>"

      tableStyle = @style
        'border-collapse': 'collapse'
        border: '1px solid black'
        'max-width': opts.maxWidth
        'min-width': opts.minWidth

      headerStyle = @style
        'background': 'gray'
        color: 'rgb(255, 231, 135)'

      @rawHtml """
      <table #{tableStyle}>
        <thead #{headerStyle}><tr>#{headerCells.join('\n')}</tr></thead>
        <tbody>#{rows.join('\n')}</tbody>
      </table>
      """
    else
      @paragraph "... no rows ...", bold: true

  # Public: Generate the final HTML string.
  # Returns a {String} containing our completed HTML email.
  generate: ->
    """
    <html>
      <body>
        #{@body}
      </body>
    </html>
    """
