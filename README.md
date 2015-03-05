# sqlquest-reporting

This is a simple sqlquest plugin for doing simple reporting from
[sqlquest](https://github.com/scopely/sqlquest) jobs.

## Usage

```
$ npm install --save sqlquest-reporting
```

Then in your quest you can do stuff like this:

```coffee
Quest = require 'sqlquest'

module.exports =
  class EmailReportQuest extends Quest
    plugins: [
      'sqlquest-reporting'
    ]

    adventure: ->
      @report "ses",
        from: "person@people.org"
        to: @opts._
        subject: "Omg it works"
        html: (builder) =>
          builder.header "Hi kids"
          builder.header "Do you like violence?", 'small'
          builder.paragraph "Wanna copy me and do exactly like I did?",
            italic: true
            bold: true

          link = builder.link "http://genius.com/Eminem-my-name-is-lyrics",
            "Try <bleep> and get <bleep> worse than my life is?"
          builder.paragraph link

          builder.table @sql("SELECT * FROM stv_recents limit 10;"),
            wrap: ['query']
```

Right now the only reporter we have is an SES implementation using AWS, but
we'd love to have more options!

To use the `ses` reporter, make sure you set the normal AWS credentials env
vars:

```
AWS_ACCESS_KEY_ID=things AWS_SECRET_ACCESS_KEY=stuff ./sqlquest ..
```
