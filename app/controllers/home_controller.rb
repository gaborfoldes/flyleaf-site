class HomeController < ApplicationController
  def index
  end

  def upload

    require 'net/http'
    require 'SecureRandom'
    require 'FileUtils'

    uploaded_io = params[:epub]
    # uploaded_io.original_filename
    shortened = SecureRandom.urlsafe_base64(4)
    shortened_epub = shortened + '.epub'
    FileUtils.mkdir_p(Rails.root.join('public', '.epub', shortened, 'original'))
    File.open(Rails.root.join('public', '.epub', shortened, 'original', shortened_epub), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    url = URI.parse('http://localhost:3001/load/' + shortened)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    if res.body == 'OK' 
    	puts shortened
    end

    redirect_to 'http://localhost:3001/view/' + shortened  #home_index_path
#    render :action => :index
  end

end
