title: ProScribe manual
brief: Crappy source documentation tool.
--

## Installation

    $ gem install proscribe

## Usage

Make your code project ProScribe-able using `proscribe new`.

    $ proscribe new
      create   Scribefile
      create   manual/
      create   manual/index.md

Now edit your files in `manual/` and inline comments in your source code.

To build documentation HTML, use:

    $ proscribe build

This builds HTML in `doc/` by default.

You may also preview your changes in real time:

    $ proscribe start
    * Starting server...
    >> Thin web server (v1.2.11 codename Bat-Shit Crazy)
    >> Maximum connections set to 1024
    >> Listening on 0.0.0.0:4833, CTRL+C to stop

Then point your browser to `http://localhost:4833` to see your changes in real 
time.
