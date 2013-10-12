require "sinatra"
require "rdiscount"
require "yaml"

set :haml, :format => :html5

get "/" do
  haml :index
end

get "/blog" do
  items  = Dir["posts/*"]
  @posts = items.map { |str| str.match(/posts\/(.*).md/)[1] }
  haml :blog
end

get "/blog/:id" do
  path   = File.expand_path("posts/#{params[:id]}.md")
  text   = File.read(path)
  parsed = parse_post(text)
  data   = parsed[0]

  # Set the posts variables
  data.each { |k,v| instance_variable_set("@#{k}", v) }

  # Set the content
  markdown = RDiscount.new(parsed[1])
  @content = markdown.to_html

  haml :post, :layout => :post_layout
end

get "/base.css" do
  scss :base
end

# Parses the post
#
# content - The contents of the post
#
# Returns an Array
def parse_post(content)
  begin
    matches     = content.match(/\A---\s*\n.*?\n?(.*)---\s*$\n?(.*)/m)
    data_str    = matches[1]
    content_str = matches[2]

    if matches
      data = YAML.load(data_str)
    end
  rescue SyntaxError => e
    puts "YAML Exception reading content #{content}: #{e.message}"
  rescue Exception => e
    puts "Error reading content: #{e.message}"
  end
  [data || {}, content_str]
end
