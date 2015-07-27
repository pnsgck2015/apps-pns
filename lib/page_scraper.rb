require 'nokogiri'

load_arr = [] # TODO, load site specific plugings 
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

class PageScraper
	
	def initialize(args_hash = {})
			
	end
		
	def get_scraped_data(page_content_hash,args_hash = {})
		return nil if not (page_content_hash and page_content_hash["content"])
		dom = get_dom_from_html_content(page_content_hash["content"])
		return nil if not dom
		# TODO, should load site specific plunings and scrape data
		data = {}
		size = args_hash["size"].downcase
		data["url"] = args_hash["url"]
		data["size"] = size
		size_hash = {}
		dom.xpath("//ul[contains(@id,'ProductSizes')]/li").each do |node|
			next if not node
			name = node.content.chomp.strip.downcase 
			next if not name or name.empty?
			onclick_node = node.xpath("./@onclick").first
		     	text = onclick_node.content.chomp.strip	
			if text and text.match(/not\s+Available/i)
				size_hash[name] = "Not Available"
			else
				size_hash[name] = "Available"
			end
		end
		puts "size hash #{size_hash}"
		if size_hash[size]
			data["size_availability"] = size_hash[size] 
		else
			data["size_availability"] = "Invalid size for this product" 
		end
		return data	
	end

	def get_dom_from_html_content(content)
		return nil if not content
		dom = nil
		begin
			dom = Nokogiri::HTML(content)
		rescue Exception => e
			$log.info "Exception: #{e.class} -> #{e.messgae} at #{__LINE__} in #{__FILE__}"
		end
		return dom
	end	
		
end
