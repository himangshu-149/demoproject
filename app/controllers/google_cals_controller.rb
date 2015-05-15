require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'
require 'base64'
class GoogleCalsController < ApplicationController
	def get_authorize_using_jwtasserter
		key = Google::APIClient::KeyUtils.load_from_pkcs12('rentlycalendar-7bbc7ed53b98.p12', 'notasecret')
		client = Google::APIClient.new({:application_name => "rentlycalendar"})
		#asserter = Google::APIClient::JWTAsserter.new(
		 #   '361602138933-vi8o9uv855ms8ophdklv2l1gci3udk9g@developer.gserviceaccount.com',
		 #   'https://www.googleapis.com/auth/calendar', 
		 #   key)
		client.authorization = Signet::OAuth2::Client.new(
		  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
		  :audience => 'https://accounts.google.com/o/oauth2/token',
		  :scope => 'https://www.googleapis.com/auth/calendar',
		  :issuer => '361602138933-vi8o9uv855ms8ophdklv2l1gci3udk9g@developer.gserviceaccount.com',
		  :signing_key => key)
#=begin
		#client.authorization = asserter.authorize
		client.authorization.fetch_access_token!
		logger.info ">>>>>>>>>>#{client.authorization.access_token}>>>>>>>>>>>>>>"
		#logger.info "=============#{asserter.methods}=========#{client.authorization.access_token}=====#{client.authorization.fetch_access_token!}========"
		service = client.discovered_api('calendar', 'v3')
		@result = client.execute(:api_method => service.calendar_list.list,
				:parameters => {},
				:headers => {'Content-Type' => 'application/json'})
		@calendar_list = client.execute(:api_method => service.calendar_list.get,
			            :parameters => {'calendarId' => 'primary'})
#=end
		
		########################## Fetching event list ######################################
#=begin
		page_token = nil
		@events_hash = []
		@result1 = client.execute(:api_method => service.events.list,
					:parameters => {'calendarId' => 'primary'})
		client.execute(:api_method => service.events.delete,
                        :parameters => {'calendarId' => 'primary', 'eventId' => '7gt5arcq02901rgl4b4g0sge2s@google.com'})
		logger.info "=============#{@result1.data}========"
		while true
			events = @result1.data.items
			events.each do |e|
				logger.info "====#{e.summary}\n"
				_temp = {}
				_temp["id"] = e.iCalUID
				_temp["summary"] = e.summary
				_temp["organizer"] = e.organizer.email
				_temp["attendees"] = e.attendees.collect {|e| e.email}.join(",")
				_temp["start_date_time"] = e.start.dateTime
				_temp["end_date_time"] = e.end.dateTime
				@events_hash << _temp
			end
			if !(page_token = @result1.data.next_page_token)
				break
			end
			@result1 = client.execute(:api_method => service.events.list,
					  :parameters => {'calendarId' => 'primary',
					                  'pageToken' => page_token})
		end
#=end
		#####################################################################################
=begin
		event = {
			  'summary' => 'Meeting for today', #put summary in here
			  'location' => 'Rabindra Sadan', #put location in here
			  'start' => {
			    'dateTime' => '2015-05-13T17:00:00.000+05:30' #put start time in here
			  },
			  'end' => {
			    'dateTime' => '2015-05-13T18:00:00.000+05:30' #put end time in here
			  },
			  'timeZone' => 'Asia/Calcutta', #put timezone here
			  'attendees' => [
			    {
			      'email' => 'sourav@bitcanny.com' #put attendees email here
			    }]
			}
			@result2 = client.execute(:api_method => service.events.insert,
						:parameters => {'calendarId' => 'primary'},
						:body => JSON.dump(event),
						:headers => {'Content-Type' => 'application/json'})
=end
	end

	def create_new_event
		key = Google::APIClient::KeyUtils.load_from_pkcs12('rentlycalendar-7bbc7ed53b98.p12', 'notasecret')
		client = Google::APIClient.new({:application_name => "rentlycalendar"})
		client.authorization = Signet::OAuth2::Client.new(
		  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
		  :audience => 'https://accounts.google.com/o/oauth2/token',
		  :scope => 'https://www.googleapis.com/auth/calendar',
		  :issuer => '361602138933-vi8o9uv855ms8ophdklv2l1gci3udk9g@developer.gserviceaccount.com',
		  :signing_key => key)
		client.authorization.fetch_access_token!
		service = client.discovered_api('calendar', 'v3')
		event = {
		  'summary' => 'Come to Office', #put summary in here
		  'location' => 'Rabindra Sadan', #put location in here
		  'start' => {
		    'dateTime' => '2015-05-18T10:00:00.000+05:30' #put start time in here
		  },
		  'end' => {
		    'dateTime' => '2015-05-18T14:00:00.000+05:30' #put end time in here
		  },
		  'timeZone' => 'Asia/Calcutta', #put timezone here
		  'attendees' => [
		    {
		      'email' => 'bitcanny.com_u0d9opn8gub185aie6sr3rujqc@group.calendar.google.com' #put attendees email here
		    }]
		}
		@result2 = client.execute(:api_method => service.events.insert,
					:parameters => {'calendarId' => 'bitcanny.com_u0d9opn8gub185aie6sr3rujqc@group.calendar.google.com'},
					#:parameters => {'calendarId' => 'primary'},
					:body => JSON.dump(event),
					:headers => {'Content-Type' => 'application/json'})

		logger.info ">>>Resonse>>>>>#{@result2.data}>>>>>>"
		redirect_to get_authorize_using_jwtasserter_path
	end

	def index
=begin
		create_header
		#@header = Base64.urlsafe_encode64(@header.to_s)
		@header = Base64.encode64(@header.to_s)

		create_claim_set
		#@claim_set = Base64.urlsafe_encode64(@claim_set.to_s)
		@claim_set = Base64.encode64(@claim_set.to_s)
		
		create_ascii_arr("#{@header}.#{@claim_set}")
		#@sin_arr = Base64.urlsafe_encode64(@sin_arr.to_s)
		@sin_arr = Base64.encode64(@sin_arr.to_s)

		create_grant_type
		#@grant_type = Base64.urlsafe_encode64(@grant_type.to_s)
		@grant_type = Base64.encode64(@grant_type.to_s)

		@assertion = "#{@header}.#{@claim_set}.#{@sin_arr}"

		#render :text => "#{@grant_type}  <br> #{@header} <br> #{@claim_set} <br> #{@sin_arr} <br><br>#{@header}<br>eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9"
=end
		
	end

	def insert_new_event
		key = Google::APIClient::KeyUtils.load_from_pkcs12('rentlycalendar-7bbc7ed53b98.p12', 'notasecret')
		client = Google::APIClient.new({:application_name => "rentlycalendar"})
		asserter = Google::APIClient::JWTAsserter.new(
		   '361602138933-vi8o9uv855ms8ophdklv2l1gci3udk9g@developer.gserviceaccount.com',
		   'https://www.googleapis.com/auth/calendar', 
		   key)
		client.authorization = asserter.authorize
		service = client.discovered_api('calendar', 'v3')
		event = {
		  'summary' => params["summary"], #put summary in here
		  'location' => params["location"], #put location in here
		  'start' => {
		    'dateTime' => params["start_date_time"] #put start time in here
		  },
		  'end' => {
		    'dateTime' => params["end_date_time"] #put end time in here
		  },
		  #'timeZone' => 'Asia/Calcutta', #put timezone here
		  'timeZone' => 'America/Los Angeles', #put timezone here
		  'attendees' => [
		    {
		      'email' => params["attendees_email"] #put attendees email here
		    }]
		}
		@result2 = client.execute(:api_method => service.events.insert,
					#:parameters => {'calendarId' => 'bitcanny.com_u0d9opn8gub185aie6sr3rujqc@group.calendar.google.com'},
					:parameters => {'calendarId' => 'primary'},
					:body => JSON.dump(event),
					:headers => {'Content-Type' => 'application/json'})
		redirect_to root_path
	end

	def get_event_from_calendar

	end

	def show_events
		key = Google::APIClient::KeyUtils.load_from_pkcs12('rentlycalendar-7bbc7ed53b98.p12', 'notasecret')
		client = Google::APIClient.new({:application_name => "rentlycalendar"})
		asserter = Google::APIClient::JWTAsserter.new(
		   '361602138933-vi8o9uv855ms8ophdklv2l1gci3udk9g@developer.gserviceaccount.com',
		   'https://www.googleapis.com/auth/calendar', 
		   key)
		client.authorization = asserter.authorize
		service = client.discovered_api('calendar', 'v3')
		@result = client.execute(:api_method => service.events.list,
					#:parameters => {'calendarId' => 'onlinesd.1986@gmail.com'},
					:parameters => {'calendarId' => params["calendarId"]},
					#:parameters => {'calendarId' => 'primary'},
					:headers => {'Content-Type' => 'application/json'})

		########################## Fetching event list ######################################
#=begin
		page_token = nil
		@events_hash = []
		while true
			events = @result.data.items
			events.each do |e|
				#if e.attendees.collect {|e| e.email}.join(",").include?(params["calendarId"])
					logger.info "====#{e.summary}\n"
					_temp = {}
					_temp["id"] = e.iCalUID
					_temp["summary"] = e.summary.present? ? e.summary : ""
					_temp["organizer"] = e.organizer.present? ? e.organizer.email : ""
					_temp["attendees"] = e.attendees.present? ? e.attendees.collect {|e| e.email}.join(",") : ""
					_temp["start_date_time"] = e.start.present? ? e.start.dateTime : ""
					_temp["end_date_time"] = e.end.present? ? e.end.dateTime : ""
					@events_hash << _temp
				#end
			end
			if !(page_token = @result.data.next_page_token)
				break
			end
			@result = client.execute(:api_method => service.events.list,
					  :parameters => {'calendarId' => params["calendarId"],
					                  'pageToken' => page_token})
		end
	end

	def get_free_busy_events
		key = Google::APIClient::KeyUtils.load_from_pkcs12('rentlycalendar-7bbc7ed53b98.p12', 'notasecret')
		client = Google::APIClient.new({:application_name => "rentlycalendar"})
		asserter = Google::APIClient::JWTAsserter.new(
		   '361602138933-vi8o9uv855ms8ophdklv2l1gci3udk9g@developer.gserviceaccount.com',
		   'https://www.googleapis.com/auth/calendar', 
		   key)
		client.authorization = asserter.authorize
		service = client.discovered_api('calendar', 'v3')
		@result = client.execute(
					:api_method => service.freebusy.query,
					#:parameters => {'calendarId' => 'onlinesd.1986@gmail.com'},
					:body => JSON.dump({
					    :timeMin => Time.now,
					    :timeMax => Time.now + 8.days,
					    :items => [{
					    	:id => params["calendarId"]
					    	}]
					}),
					#:parameters => {'calendarId' => 'primary'},
					:headers => {'Content-Type' => 'application/json'})
=begin
		page_token = nil
		@events_hash = []
		while true
			events = @result.data.items
			events.each do |e|
				#if e.attendees.collect {|e| e.email}.join(",").include?(params["calendarId"])
					logger.info "====#{e.summary}\n"
					_temp = {}
					_temp["id"] = e.iCalUID
					_temp["summary"] = e.summary.present? ? e.summary : ""
					_temp["organizer"] = e.organizer.present? ? e.organizer.email : ""
					_temp["attendees"] = e.attendees.present? ? e.attendees.collect {|e| e.email}.join(",") : ""
					_temp["start_date_time"] = e.start.present? ? e.start.dateTime : ""
					_temp["end_date_time"] = e.end.present? ? e.end.dateTime : ""
					@events_hash << _temp
				#end
			end
			if !(page_token = @result.data.next_page_token)
				break
			end
			@result = client.execute(:api_method => service.events.list,
					  :parameters => {'calendarId' => params["calendarId"],
					                  'pageToken' => page_token})
		end
=end
	end

	def create_header
		#@header = {:alg => "RS256", :typ => "JWT"}
		@header = {}
		@header["alg"] = "RS256"
		@header["typ"] = "JWT"
		#@header = "{'alg':'RS256','typ':'JWT'}"
	end

	def create_claim_set
		@claim_set = {
		  :iss => "1086041807445-8vhabets2pea2q9vnhul9obqkcc185mt@developer.gserviceaccount.com",
		  :scope => "https://www.googleapis.com/auth/calender",
		  :aud => "https://www.googleapis.com/oauth2/v3/token",
		  :exp => Time.now.to_i+3600,
		  :iat => Time.now.to_i
		}
	end

	def create_ascii_arr(key_str)
		@sin_arr = []
		key_str.each_byte do |c|
		   @sin_arr<<c
		end
	end

	def create_grant_type
		@grant_type = {"urn" => "ietf", "params" => "oauth", "grant-type" => "jwt-bearer"}
	end
end
