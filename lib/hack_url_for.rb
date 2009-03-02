# TODO send url_for patch to webby
module Webby::Helpers
  module UrlHelper
    def url_for( *args )
      opts = Hash === args.last ? args.pop : {}
      obj = args.first

      anchor = opts.delete(:anchor)
      escape = opts.has_key?(:escape) ? opts.delete(:escape) : true

      url = Webby::Resources::Resource === obj ? obj.url : obj.to_s
      url = escape_once(url) if escape
      url << "#" << anchor if anchor

      # hack hack
      url.gsub!(/\.html$/, "") if url[0].chr == "/"
      return url
    end
  end
end
