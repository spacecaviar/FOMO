class PdfGenerator

  def self.generate_pdf(tweets)
    pdf = Prawn::Document.new(:page_size => [800, 900], :page_layout => :landscape) do
      tweets.each_with_index do |tweet, j|
        #start_new_page(:size => [800, 900], :layout => :landscape) unless j == 0
        stroke do
          url = tweet.user.profile_image_url
          #uri = URI.encode(url)
          image open(url.to_s), :position => :left
          text tweet.user.name, :position => :left
          text tweet.text, :position => :right
        end
      end
    end
    pdf.render
  end

end