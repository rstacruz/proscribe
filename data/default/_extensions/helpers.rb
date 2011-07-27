module Proton::Helpers
  def page_children(page)
    children = page.children
    of_type  = lambda { |str| children.select { |p| p.html? && p.meta.page_type == str } }

    children.
      select { |p| p.html? }.
      group_by { |p|
        type = p.meta.page_type
        type.nil? ? nil : Inflector[type].pluralize.to_sym
      }
  end

  # A link to the source file on GitHub
  def github_source_link
    if project.config.github && project.config.git
      if page.meta.source_file
        "https://github.com/#{project.config.github}/blob/#{project.config.git[0..6]}/#{page.source_file}#L#{page.source_line}".squeeze('/')
      end
    end
  end
end

# Inflector['hello'].pluralize
class Inflector < String
  def self.[](str)
    new str.to_s
  end

  def pluralize
    if self[-1] == 's'
      "#{self}es"
    else
      "#{self}s"
    end
  end

  def sentencize
    self.gsub('_', ' ').capitalize
  end
end
