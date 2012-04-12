require "redcarpet"
require "active_support/core_ext"
require "coderay"

# Debugging
set(:logging, ENV['RACK_ENV'] != 'production')

###
# Blog
###

activate :blog
set :blog_sources, "blog/:year-:month-:day-:title.html"
set :blog_permalink, "blog/:year/:month/:day/:title.html"
set :blog_layout, 'blog'

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

class TableOfContents < Redcarpet::Render::Base
  def initialize
    @current_level = 0
    @toc_count = 0
    @result = []
    super
  end

  def header(text, level)
    @toc_count += 1

    return if level > 3

    result = @result

    if level > @current_level
      while level > @current_level
        result << "<ul>\n<li>\n"
        @current_level += 1
      end
    elsif level < @current_level
      result << "</li>\n"

      while level < @current_level
        result << "</ul>\n</li>\n"
        @current_level -= 1
      end

      result << "<li>\n"
    else
      result << "</li>\n<li>\n"
    end

    result << "<a href=\"#toc_#{@toc_count-1}\">#{text}</a>"

    ""
  end

  def postprocess(text)
    @result.join("")
  end
end

helpers do
  def link_to_page name, url
    path = request.path
    current = path =~ Regexp.new(url)

    if path == '/index.html' and name == 'docs'
      current = true
    end

    class_name = current ? ' class="active"' : ''

    "<li#{class_name}><a href=\"#{url}\">#{name}</a></li>"
  end

  def table_of_contents
    chapters = data.docs.chapters

    chapters = chapters.collect_concat do |file|
      File.read("source/docs/#{file}.md")
    end

    toc = TableOfContents.new()
    markdown = Redcarpet::Markdown.new(toc, fenced_code_blocks: true)

    markdown.render(chapters.join(''))
  end
  def highlight(language, class_name, &block)
    concat %Q{<div class="highlight #{class_name} #{language}">}
    concat '<div class="ribbon"></div>'
    code = capture(&block)
    code.gsub!(/^\n+/, '')
    code.rstrip!
    code = CodeRay.scan(code, language)
    concat code.div css: :class,
                    line_numbers: :table,
                    line_number_anchors: false

    concat %Q{</div>}
  end

  # The default one is buggy as of beta 2
  def wrap_layout(layout_name, &block)
    # Save current buffer for later
    @_out_buf, _buf_was = "", @_out_buf
    begin
      content = capture(&block) if block_given?
    ensure
      # Reset stored buffer
      @_out_buf = _buf_was
    end
    layout_path = locate_layout(layout_name, current_engine)

    if !@_out_buf
      raise "wrap_layout is currently broken for this templating system"
    end

    @_out_buf.concat render_individual_file(layout_path, @current_locs || {}, @current_opts || {}, self) { content }
  end
end

class HighlightedHTML < Redcarpet::Render::HTML
  def block_code(code, language)
    code
    # Pygments.highlight(code, :lexer => language)
  end
end

set :md, :layout_engine => :erb,
         :fenced_code_blocks => true,
         :lax_html_blocks => true,
         :renderer => HighlightedHTML.new(:with_toc_data => true)

activate :directory_indexes

page "documentation.html" do
  @chapters = data.docs.chapters
end

page "community.html" do
  @chapters = data.community.chapters
end

page "examples/*", :directory_index => false

page "index.html", :proxy => "documentation.html"

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css
  
  # Minify Javascript on build
  # activate :minify_javascript
  
  # Enable cache buster
  # activate :cache_buster
  
  # Use relative URLs
  # activate :relative_assets
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
end
