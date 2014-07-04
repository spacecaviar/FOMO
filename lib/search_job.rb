require 'open-uri' 
class SearchJob < Struct.new(:geolocation, :last_tweet_id, :instagram, :twitter, :time_interval, :distance, :latitude, :longitude, :key, :last_instagram_id, :city, :country)
	
	def perform
		count_record = Count.last
		if count_record.blank?
			count_record = Count.create(:count => 0)
		end		
		count_status = count_record.update(:count => count_record.count + 1)
		count_no = count_record.count
		time_delayed = Time.now.utc + time_interval.to_i.minutes - 45.seconds
		hashtags = []
		#time_delayed = Time.now.utc + 1.minute
		#time_delayed = Time.now.utc + 20.seconds
		get_client
		time_instagram = (Time.now.utc - time_interval.to_i.minutes).to_i
		instagram_client = Instagram.client(:access_token => "1315053350.5b9e1e6.4eea0c712f504b22ab1be87b0e14b6a6")
        if geolocation == "on"
    	  if instagram == "on"
    	  	min_timestamp = (Time.now.utc - time_interval.to_i.minutes).to_i
    	  	hashtags = instagram_client.media_search(latitude,longitude, :distance=> distance,:min_timestamp => "#{min_timestamp}", :count => 100)
			#hashtags = instagram_client.tag_recent_media("#{key}", :count => 10) 
          #hashtags = instagram_client.tag_recent_media("#{key}", :count => 25)   
		  # new_last_instagram_id = hashtags.pagination.next_min_id
			new_last_instagram_id = ''
    	  end

          if twitter == "on"
			geoloc = [latitude,longitude,distance].join(',')
			if key.present?
			  tweets =  @client.search("##{key}", :since_id => last_tweet_id, :result_type => "recent").take(5000)
			  #tweets =  @client.search("##{key}", :since_id => last_tweet_id, :result_type => "recent", :geocode => geoloc).take(5000)
			  #tweets =  @client.search("##{key}", :result_type => "recent", :geocode => geoloc).take(25)
			  #tweets =  @client.search("##{key}", :result_type => "recent", :since_id => last_tweet_id).take(5000)
		      new_last_tweet_id = tweets[0].blank? ? last_tweet_id : tweets[0].id
		    else 
			 tweets =  @client.search("", :geocode => geoloc, :since_id => last_tweet_id).take(5000)
			 #tweets =  @client.search("##{key}", :result_type => "recent", :geocode => geoloc).take(25)
			  new_last_tweet_id = tweets[0].blank? ? last_tweet_id : tweets[0].id
			end
		  end
		else
		 if instagram == "on"
          hashtags = instagram_client.tag_recent_media("#{key}", :count => 400, :min_timestamp => last_instagram_id) 
          #hashtags = instagram_client.tag_recent_media("#{key}", :count => 25)   
		   new_last_instagram_id = hashtags.pagination.next_min_id
		 end
		  if twitter == "on"
           	tweets =  @client.search("##{key}", :result_type => "recent", :since_id => last_tweet_id).take(5000)
            #tweets =  @client.search("##{key}", :result_type => "recent", :geocode => geoloc).take(25)

		    new_last_tweet_id = tweets[0].blank? ? last_tweet_id : tweets[0].id
		  end
        end
        ac = ActionController::Base.new()
		html = ac.render_to_string :partial => 'tweets/geolocation_search', :encoding => "UTF-8", :locals => {:session => {:twitter => twitter, :instagram => instagram, :pdf => true}, :hashtags => hashtags, :tweets => tweets, :distance => distance, :latitude => latitude, :longitude => longitude, :key => key, :time_instagram => time_instagram,:count_no => count_no, :city => city, :country => country,:geolocation => geolocation}
		pdf = PDFKit.new(html, :page_width =>'182', :page_height => '257', :margin_top => "0.3in", :margin_bottom => "0.3in", :margin_left => "0.4in", :margin_right => "0.1in")
  	    pdf.stylesheets << "#{Rails.root}/app/assets/stylesheets/test.css"
  	    pdf_path = Rails.root.join('public/pdf', "F0M0#{count_no}.pdf")
  	    File.open(pdf_path, 'wb') do |file|
    	  file << pdf.to_pdf 
        end
       Delayed::Job.enqueue(SearchJob.new(geolocation,new_last_tweet_id, instagram, twitter, time_interval, distance, latitude, longitude, key, new_last_instagram_id, city, country), priority: 28, run_at: time_delayed, :queue => "#{key}lat#{latitude}lng#{longitude}")
		
  end

	def get_client
  		@client = Twitter::REST::Client.new do |config|
	  		config.consumer_key        = "5rHv2ZmtpLT5ANcRwP6HnWFnI"
	  		config.consumer_secret     = "2HqQ1zcQDsCSauD5mKa8DDh6F8n6KXEH2vtw4m9MRBcs6QxBkB"
	  		config.access_token        = "2381587561-PAfyvBC02Ne8E6x4YFrla4LIQUOuOb7An1qzpLM"
	  		config.access_token_secret = "XrKEVZ6wZ9artQmn9GKYDiyZirB0yJf8GFJpqckzXdtCH"
	  	end
  	end

end
