title: ProScribe manual
brief: Crappy source documentation tool.
--

    $ gem install proscribe

#### Enable ProScribe
Make your code project ProScribe-able using `proscribe new`.

    $ proscribe new
      create   Scribefile
      create   manual/
      create   manual/index.md
    </pre>

#### Inline comments
Now edit your files in `manual/` and inline comments in your source code. Use Markdown!

    # Class: Adaptor
    # Adapts insteads of dying.
    #
    # ## Usage
    #
    #     a = Adaptor.new(plug)
    #
    # ## Description
    #
    #   This is a great class.
    #
    class Adaptor
      # ...
    end
    </pre>

#### Build as HTML

To build documentation HTML, use this. This builds HTML in `doc/` by default.

    $ proscribe build
      ...

    $ ls doc/
      index.html
      style.css
      ...

#### Real-time previews
You may also preview your changes in real time. Do this, then point your browser to `http://localhost:4833` to see your changes in real time.

    $ proscribe start
    * Starting server...
    >> Thin web server (v1.2.11 codename Bat-Shit Crazy)
    >> Maximum connections set to 1024
    >> Listening on 0.0.0.0:4833, CTRL+C to stop

[Source code](http://github.com/rstacruz/proscribe "Source code")
