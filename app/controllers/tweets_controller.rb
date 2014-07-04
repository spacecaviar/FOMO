class TweetsController < ApplicationController
	require 'open-uri'
	require 'nokogiri'
	require 'cgi'

	def download_tweets
	
		count_record = Count.last
		count_status = count_record.update(:count => count_record.count + 1)
		@count_no = Count.last.count 
		html = render_to_string :partial => "test", :encoding => "UTF-8"
			#template_footer = File.read "#{Rails.root}/app/views/tweets/footer.html"
			

			pdf = PDFKit.new(html, :page_width =>'182', :page_height => '257', :margin_top => "0.2in", :margin_bottom => "0.2in", :margin_left => "0.2in", :margin_right => "0.2in",:header_right => ". [page]", :footer_html => "#{Rails.root}/app/views/tweets/footer.html" ) 
    		pdf.stylesheets << "#{Rails.root}/app/assets/stylesheets/test.css"
    		#pdf.stylesheets << "#{Rails.root}/app/assets/stylesheets/font.css"
    		pdf_path = Rails.root.join('tmp/pdf', "recent.pdf")
    		#pdf.to_file( "#{Rails.root}/tmp/pdf/recent.pdf")
    		
  			File.open(pdf_path, 'wb') do |file|
			file << pdf.to_pdf 
			
			end
			
			send_file pdf_path
	end

	def geolocation_search
        instagram_client = Instagram.client(:access_token => "1315053350.5b9e1e6.4eea0c712f504b22ab1be87b0e14b6a6")
        last_instagram_id = ''
        last_tweet = []
        location = []
		unless params[:commit] == "Stop"
			session[:start] = "on"
			Delayed::Job.where(:queue => "#{session[:key]}lat#{session[:latitude]}lng#{session[:longitude]}").delete_all
			get_client
			session[:geolocation] = params[:geolocation] 
			interval = "#{params[:search_data][:time_interval]}"
			session[:time_interval] = params[:search_data][:time_interval]
			#session[:time_interval] = 1
			time_delayed = Time.now.utc + session[:time_interval].to_i.minute - 45.seconds
			#time_delayed = Time.now.utc + 30.seconds
			radius = "#{params[:search_data][:radius]}"
			tweet_distance = Radius.find(radius).radius.to_i * 5
			@distance = "#{tweet_distance}km"
			session[:latitude] = params[:latitude].to_f.round(4).to_s
			session[:longitude] = params[:longitude].to_f.round(4).to_s
			geoloc = [session[:latitude], session[:longitude], @distance].join(',')
			session[:key] = params[:tweet]
			if session[:geolocation] == "on"
				@location = Geocoder.search("#{params[:latitude]}, #{params[:longitude]}")
				if session[:key].present?
					last_tweet = @client.search("##{session[:key]}", :result_type => "recent", :geocode => geoloc).take(1)
				else
					last_tweet = @client.search("", :result_type => "recent", :geocode => geoloc).take(1)						
				end
				#last_instagram_id = instagram_client.media_search(session[:latitude],session[:longitude], :distance=> 5,:min_timestamp => "1401526883", :count => 100)
				#last_instagram_id = last_instagram_id.pagination.min_tag_id
				last_instagram_id = ''
			else
			  begin
			    val = Geocoder.search(ip_address)
			   # val = Geocoder.search("182.64.56.7")
		        @lat_lon = [val[0].latitude, val[0].longitude]
		      rescue
			    @lat_lon = [48.8567,2.3508]
		      end
		      
		      @location = Geocoder.search("#{@lat_lon[0] }, #{@lat_lon[1] }")
		      last_instagram_id = instagram_client.tag_recent_media("#{session[:key]}", :count => 1) 	
			  last_instagram_id = last_instagram_id.pagination.min_tag_id
			  last_tweet = @client.search("##{session[:key]}", :result_type => "recent").take(1) if session[:twitter] == "on"
			end
			session[:last_tweet_id] = last_tweet[0].blank? ? '' : "#{last_tweet[0].id}"
			
		     Delayed::Job.enqueue(SearchJob.new(session[:geolocation],"#{session[:last_tweet_id]}", session[:instagram], session[:twitter], session[:time_interval], @distance,session[:latitude], session[:longitude], session[:key], last_instagram_id, @location[0].city, @location[0].country ), priority: 28,run_at: time_delayed, :queue => "#{session[:key]}lat#{session[:latitude]}lng#{session[:longitude]}")
			
		else
			Delayed::Job.where(:queue => "#{session[:key]}lat#{session[:latitude]}lng#{session[:longitude]}").delete_all
			session[:start] = "off"
		end
		redirect_to root_path
	end	


	def show
		session[:twitter] = "on"
		session[:instagram] = "on"
		ip_address = request.remote_ip
		begin
			val = Geocoder.search(ip_address)
			#val = Geocoder.search("182.64.56.7")
			@lat_lon = [val[0].latitude, val[0].longitude]
		rescue
			@lat_lon = [48.8567,2.3508]
		end
	end

	def set_status
		if session[params[:val]] == "on"
			session[params[:val]] = "off"
		else
			session[params[:val]] = "on"
		end
		
	end

	def pdf_generate
	count = Count.last.count
	file_path = Rails.root.join('public/pdf', "F0M0#{count}.pdf")
   	begin
   		send_file file_path
   	rescue Exception => e
   		redirect_to root_path
   	end
  end

end

	