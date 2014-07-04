class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_client
  	@client = Twitter::REST::Client.new do |config|
  		config.consumer_key        = "5rHv2ZmtpLT5ANcRwP6HnWFnI"
  		config.consumer_secret     = "2HqQ1zcQDsCSauD5mKa8DDh6F8n6KXEH2vtw4m9MRBcs6QxBkB"
  		config.access_token        = "2381587561-PAfyvBC02Ne8E6x4YFrla4LIQUOuOb7An1qzpLM"
  		config.access_token_secret = "XrKEVZ6wZ9artQmn9GKYDiyZirB0yJf8GFJpqckzXdtCH"
  	end
  end
  
  def get_instagram
   @instagram = Instagram.configure do |config|
      config.client_id = "457fd8b4a868450082b201ff1e14e4eb"
      config.client_secret = "7f2447551e2946118814a656176340d8"
      
    end
  end 
end
