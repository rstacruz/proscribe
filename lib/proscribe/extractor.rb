#!/usr/bin/env ruby

require 'ostruct'
require 'fileutils'

module ProScribe
  # Extracts comments from list of files.
  # Gets the ones with comment blocks starting with `[...]`
  #
  # == Common usage
  #
  #   ex = Extractor.new(Dir['./**/*.rb'])
  #   ex.blocks
  #
  #   ex.blocks.map! { |b| b.file = "file: #{b.file}" }
  #
  #   ex.write!('manual/')       # Writes to manual/
  #
  class Extractor
    def initialize(files, options={})
      @files = files
    end

    def write!(output_path = '.', &blk)
      blocks.each { |block|
        path = File.join(output_path, block.file)
        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w') { |f| f.write block.body }
        yield block  if block_given?
      }
    end

    # Returns an array of Extractor::Blocks.
    def blocks
      @blocks ||= begin
        @files.map { |file|
          if File.file?(file)
            input = File.read(file)
            get_blocks input
          end
        }.compact.flatten
      end
    end

  private
    # Returns blocks that match a blah.
    def get_blocks(str)
      arr = get_comment_blocks(str)
      arr.map { |block|
        re = /^([A-Za-z ]*?): (.*?)(?: \((.*?)\))?$/

        if block.last =~ re
          Extractor::Block.new \
            :type => $1,
            :title => $2,
            :parent => $3,
            :body => (block[0..-2].join("\n") + "\n")
        elsif block.first =~ re
          Extractor::Block.new \
            :type => $1,
            :title => $2,
            :parent => $3,
            :body => (block[1..-1].join("\n") + "\n")
        end
      }.compact
    end

    # Returns contiguous comment blocks.
    def get_comment_blocks(str)
      chunks = Array.new
      i = 0

      str.split("\n").each { |s|
        if s =~ /^\s*(?:\/\/\/?|##?) ?(.*)$/
          chunks[i] ||= Array.new
          chunks[i] << $1
        else
          i += 1  if chunks[i]
        end
      }

      chunks
    end
  end

  class Extractor::Block
    attr_accessor :body
    attr_accessor :file

    def initialize(options)
      title  = options[:title]
      parent = options[:parent]
      body   = options[:body]
      type   = options[:type].downcase

      file = to_filename(title, parent)
      brief, *body = body.split("\n\n")
      body = "#{body.join("\n\n")}"

      heading = "title: #{title}\npage_type: #{type}\nbrief: #{brief}\n"
      heading += "--\n"

      @file = file
      body  = Tilt.new(".md") { body }.render
      body  = fix_links(body, from: file)
      @body = heading + body
    end

  private
    def fix_links(str, options={})
      from = ("/" + options[:from].to_s).squeeze('/')
      depth = from.to_s.count('/')
      indent = (depth > 1 ? '../'*(depth-1) : './')[0..-2]

      # First pass: {Helpers::content_for} to become links
      str = str.gsub(/{([^}]*?)}/) { |s|
        s = s.gsub(/{|}/, '')

        m = s.match(/^(.*?)[:\.]+([A-Za-z_\(\)\!\?]+)$/)
        if m
          name, context = $2, $1
        else
          name, context = s, nil
        end

        s = "<a href='/#{to_filename(s, '', :ext => '.html')}'>#{name}</a>"
        s += " <span class='context'>(#{context})</span>"  if context
        s
      }

      # Second pass: relativize
      re = /href=['"](\/(?:.*?))['"]/
      str.gsub(re) { |s|
        url = s.match(re) && $1
        url = "#{indent}/#{url}".squeeze('/')
        "href=#{url.inspect}"
      }
    end

    def to_filename(title, parent='', options={})
      extension = options[:ext] || '.erb'
      pathify = lambda { |s|
        s.to_s.scan(/[A-Za-z0-9_\!\?]+/).map { |chunk|
          chunk = chunk.gsub('?', '_question')
          chunk = chunk.gsub('!', '_bang')

          if chunk[0].upcase == chunk[0]
            chunk
          else
            "#{chunk}_"
          end
        }.join("/").downcase
      }

      (pathify["#{parent}/#{title}"] + extension)
    end
  end
end
