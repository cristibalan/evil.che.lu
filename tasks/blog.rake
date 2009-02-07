namespace :blog do

  desc "Create a new blog post"
  task :post do |t|
    template = "#{Webby.site.template_dir}/blog/post.erb"

    page, title, dir = Webby::Builder.new_page_info

    basename = File.basename(page)
    page = "#{Time.now.strftime('%Y-%m-%d')}-#{basename}"
    page = File.join(dir, "_posts", page)
    page = Webby::Builder.create(page, :from => template,
               :locals => {:title => title, :directory => dir, :filename => basename})
    exec(::Webby.editor, page) unless ::Webby.editor.nil?
  end

  task :create_indexes do |t|
    dir = "_posts"

    # years_with_months will be something like
    # { "2007" => ["02", "11"], "2008" => ["03", "06"] }
    posts = Dir.glob(File.join(Webby.site.content_dir, dir, '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*.*')).map{|f|File.basename(f)}
    years_with_months = Hash.new { |hash, key| hash[key] = [] }
    posts.each do |post|
      year, month = post.split("-", 3)[0..1]
      years_with_months[year] << month unless years_with_months[year].include? month
    end

    require 'time'
    years_with_months.each do |year, months|
      ydir = year
      fn = File.join(ydir, 'index.haml')
      tmpl = Dir.glob(File.join(Webby.site.template_dir, 'blog/year.haml')).first.to_s
      File.unlink(File.join(Webby.site.content_dir, fn)) rescue nil
      Webby::Builder.create(fn, :from => tmpl,
          :locals => {:title => year, :directory => ydir})
      months.each do |month|
        month_human = Time.parse("#{year}-#{month}-01").strftime("%B")
        mdir = File.join(year, month)
        fn = File.join(mdir, 'index.haml')
        tmpl = Dir.glob(File.join(Webby.site.template_dir, 'blog/month.haml')).first.to_s

        File.unlink(File.join(Webby.site.content_dir, fn)) rescue nil
        Webby::Builder.create(fn, :from => tmpl,
            :locals => {:title => "#{month_human} #{year}", :directory => mdir})
      end
    end
  end

end
