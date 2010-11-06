require 'application'

Dir.chdir('public') do
  public_dirs = (Dir.glob("*").find_all{|entry| File::directory?(entry)}).collect{|dir| '/' + dir}
  use Rack::Static, :urls => public_dirs, :root => 'public'
end

run Application.new
