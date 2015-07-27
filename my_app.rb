require 'sinatra/base'

load_arr=["lib/api_controller.rb"]
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

$api_controller = APIController.new

class MyApp < Sinatra::Base
	# routers 
	get '/' do
		'TODO'
	end

	get '/help' do
		'TODO'
	end

	get '/login' do
		'TODO'
	end

	get '/logout' do
		'TODO'
	end

	get '/api' do
		response = $api_controller.get_response(params)
		set_response(response)
	end

	not_found do
		error_msg =  "API Page not found, params #{params}"
		puts error_msg
		response = $api_controller.get_error_response(404,"Page not found")
		set_response(response)
	end

	error do
		status_code = env['sinatra.error'].http_status.to_i
		puts "Sorry there was a error - " + env['sinatra.error'].message + " for params #{params}"
		response = $api_controller.get_error_response(status_code,"Server Error, we are looking into the issue")
		set_response(response)
	end

	def set_response(response = {})
		status(response[:status])
		content_type(response[:content_type], {charset: 'utf-8'}) if response[:content_type]
		body(response[:body])
	end
	# start the server if ruby file executed directly
	run! if app_file == $0
end
