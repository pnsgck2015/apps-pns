require 'open-uri'

load_arr = []
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

class PageFetcher
	
	def initialize(args_hash = {})
		#TODO	
	end
	
	def get_page_content_hash(url, args_hash ={})
		raise NullOREmptyURLException.new if not url or url.chomp.strip.empty?
		url = url.chomp.strip
		raise InvalidURLException.new if not url.match(/^http/)
		puts "fetching url #{url}"
		status = nil
		content = nil
		begin
			response = open(url)
			status   = response.status.first.to_i
			content  = response.read
		rescue OpenURI::HTTPError => e
			puts "#{e.class} -> #{e.message}"
			status = e.status.first.to_i
			#TOD, user retry as per status
		end
		raise CouldNotFetchException.new if not (status and status >= 200 and status < 400)
		raise ImproperFetchException.new if not (content and not content.empty?) # TODO, make dom and use validation xpath and apply retry
		page_content_hash = {"url" => url,
		       	"status" => status,
			"content" => content
		}
		return page_content_hash
	end
end

class NullOREmptyURLException < Exception
end
class InvalidURLException < Exception
end
class CouldNotFetchException < Exception
end
class ImproperFetchException < Exception
end

if __FILE__ == $0
	puts PageFetcher.new.get_page_content_hash(ARGV[0])
end
