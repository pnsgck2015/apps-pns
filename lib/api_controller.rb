require 'json'

load_arr = ["page_fetcher.rb","page_scraper.rb"]
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

class APIController

	def initialize(args_hash = {})
		@page_fetcher = PageFetcher.new(args_hash)
		@page_scraper = PageScraper.new(args_hash)
	end

	def get_error_response(status,error_desc)
		error_hash = {error_code: nil, # TODO, put some error code 
		error_text: error_desc
		}
		response_hash = {status: status, 
		  content_type: "application/json", 
		  body: JSON.pretty_generate(error_hash)
		}
		return response_hash
	end

	def get_response(params = {})
		puts "params: #{params}"
		args_hash = {}
		args_hash.merge!(params)
		type = params["type"]
		data = nil
		return get_formated_result(400,"Bad Request, plese pass type i.e. ../api?type=size_availability") if not type or type.empty?
		begin
			if type == "size_availability"	
				url  = params["url"]
				size = params["size"]
				return get_formated_result(400,"Bad Request, plese pass url i.e. ../api?url=<URL>") if not url or url.empty?
				return get_formated_result(400,"Bad Request, plese pass size i.e. ../api?size=<SIZE>") if not size or size.empty?
				page_content_hash = @page_fetcher.get_page_content_hash(url,args_hash)
				data = @page_scraper.get_scraped_data(page_content_hash,args_hash)
			else
				return get_formated_result(400,"Bad Request, #{type} is unknown, known are ['size_availability']")
			end
			return get_formated_result(200,"could not scrape page url #{url}") if not data or data.empty?
			return get_formated_result(200,"successfully scraped",data)
		rescue NullOREmptyURLException => e 
			return get_error_response(400,"Bad Request, url passed is null or empty")
		rescue InvalidURLException => e 
			return get_error_response(400,"Bad Request, url passed is not valid")
		rescue CouldNotFetchException => e 
			return get_formated_result(200,"could not fetch url #{url}")
		rescue ImproperFetchException => e 
			return get_formated_result(200,"could not fetch url #{url}")
		rescue Exception => e
			puts "Exception: #{e.class} -> #{e.message} for params #{params}"
			return get_error_response(500,"Server Error, we are looking into the issue")
		end
	end

	def get_formated_result(status,status_desc,data = nil)
		result_hash = {status: data ? true : false, 
		 status_desc: status_desc,
		}
		result_hash[:data] = data if data
		response_hash = {status: status, 
		  content_type: "application/json", 
		  body: JSON.pretty_generate(result_hash)
		}
		return response_hash
	end
end
