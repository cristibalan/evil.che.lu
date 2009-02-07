require "rubygems" 
require "activerecord" 
 
ActiveRecord::Base.establish_connection( 
  :adapter => "mysql", 
  :host => "localhost", 
  :username => "root", 
  :database => "tmpweb", 
  :encoding => "utf8") 
 
class Site < ActiveRecord::Base 
end
class User < ActiveRecord::Base
end
class AssignedSection < ActiveRecord::Base
  belongs_to :article
  belongs_to :section, :counter_cache => 'articles_count'
end
class Section < ActiveRecord::Base
  belongs_to :site
  has_many :assigned_sections, :dependent => :delete_all
  has_many :articles, :order => 'position', :through => :assigned_sections
end
class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
end
class Tag < ActiveRecord::Base
  has_many :taggings
end

class Content < ActiveRecord::Base 
  belongs_to :user
  belongs_to :site
end 
class Article < Content
  has_many :assigned_sections, :dependent => :destroy
  has_many :sections, :through => :assigned_sections, :order => 'sections.name'
  has_many :taggings, :as => :taggable, :class_name => '::Tagging'
  has_many :tags, :through => :taggings, :order => 'tags.name', :class_name => '::Tag'
end

FileUtils.mkdir_p("content/_posts")

posts = Article.find(:all, :conditions => { :site_id => 1})
posts.each do |post|
  author = post.user.login
  slug = post.permalink
  content = post.body

  created_at = post.published_at || Time.now
  directory = created_at.strftime('%Y/%m/%d')
  name = "#{created_at.strftime('%Y-%m-%d')}-#{slug}.textile"
  filename = File.basename(name, File.extname(name))
  p filename
  title = post.title
  categories = post.sections.map{|s|s.name.downcase}
  tags = post.tags.map{|tag| tag.name}

  data = {
    'created_at' => created_at,
    'directory'  => directory,
    'filename'   => slug,
    'extension'  => "html",
    'categories' => categories,
    'tags'       => tags,
    'title'      => title,
    'author'     => "Cristi Balan",
    'layout'     => 'post',
    'blog_post'  => true,
    'filter'     => %w(erb textile)
  }.delete_if { |k,v| v.nil? || v == '' || v.empty? rescue false }.to_yaml

  File.open("content/_posts/#{name}", "wb") do |f|
    f.puts data
    f.puts "---"
    f.puts content.gsub(//, "")
  end
end
