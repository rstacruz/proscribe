#!/usr/bin/env ruby

require 'ostruct'
require 'fileutils'

module ProScribe
  # Class: Extractor (ProScribe)
  # Extracts comments from list of files.
  #
  # ## Description
  #    Gets the ones with comment blocks starting with `[...]`
  #
  # ## Common usage
  #
  #     ex = Extractor.new(Dir['./**/*.rb'])
  #     ex.blocks
  #
  #     ex.blocks.map! { |b| b.file = "file: #{b.file}" }
  #
  #     ex.write!('manual/')       # Writes to manual/
  #
  class Extractor
    def initialize(files, root, options={})
      @files = files
      @root  = File.realpath(root)
    end

    def write!(output_path = '.', &blk)
      blocks.each { |block|
        path = File.join(output_path, block.file)
        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w') { |f| f.write block.body }
        yield block  if block_given?
      }
    end

    # Method: blocks (ProScribe::Extractor)
    # Returns an array of {Extractor::Block}s.
    def blocks
      @blocks ||= begin
        @files.map { |file|
          if File.file?(file)
            input = File.read(file)
            get_blocks(input, unroot(file))
          end
        }.compact.flatten
      end
    end

  private
    def unroot(fn)
      (File.realpath(fn))[@root.size..-1]
    end

    # Returns blocks that match a blah.
    def get_blocks(str, filename)
      arr = get_comment_blocks(str)
      arr.map { |hash|
        block = hash[:block]
        re = /^([A-Za-z ]*?): (.*?)(?: \((.*?)\))?$/

        if block.last =~ re
          Extractor::Block.new \
            :type => $1,
            :title => $2,
            :parent => $3,
            :source_line => hash[:line] + block.size + 1,
            :source_file => filename,
            :body => (block[0..-2].join("\n") + "\n")
        elsif block.first =~ re
          Extractor::Block.new \
            :type => $1,
            :title => $2,
            :parent => $3,
            :source_line => hash[:line] + block.size + 1,
            :source_file => filename,
            :body => (block[1..-1].join("\n") + "\n")
        end
      }.compact
    end

    # Returns contiguous comment blocks.
    # Returns an array of hashes (:block => [line1,line2...], :line => n)
    def get_comment_blocks(str)
      chunks = Array.new
      i = 0

      str.split("\n").each_with_index { |s, line|
        if s =~ /^\s*(?:\/\/\/?|##?) ?(.*)$/
          chunks[i] ||= { :block => Array.new, :line => line }
          chunks[i][:block] << $1
        else
          i += 1  if chunks[i]
        end
      }

      chunks.compact
    end
  end

  class Extractor::Block
    attr_accessor :body
    attr_accessor :file

    def initialize(options)
      options[:type].downcase!
      body = options.delete(:body)
      type = options.delete(:type)
      file = to_filename(options[:title], options[:parent])

      # Build the hash thing.
      header  = Hash[options.map { |(k, v)| [k.to_s, v] }]

      # Extract the brief and other artifacts.
      body = body.split("\n")
      while true
        line = body.first
        if line =~ /^(.*?): (.*?)$/
          header[$1.downcase] = $2.strip
          body.shift
        else
          brief = body.shift
          break
        end
      end
      body = body.join("\n")

      # Build the hash thing.
      header['page_type'] = type
      header['brief'] = brief
      heading = YAML::dump(header).gsub(/^[\-\n]*/, '').strip
      heading += "\n--\n"

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

      # First pass, {Helpers::content_for} to become links
      str = str.gsub(/{(?!\s)([^}]*?)(?<!\s)}/) { |s|
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

      # Second pass, relativize
      re = /href=['"](\/(?:.*?))['"]/
      str.gsub(re) { |s|
        url = s.match(re) && $1
        url = "#{indent}/#{url}".squeeze('/')
        "href=#{url.inspect}"
      }
    end

    # Private method: to_filename (ProScribe::Extractor)
    # Changes something to a filename.
    #
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
