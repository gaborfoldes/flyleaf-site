class HomeController < ApplicationController

  def index

    require 'net/http'
    require 'securerandom'
    require 'fileutils'

    if Rails.env.development?
      @api_url = 'http://localhost:3001'
    else
      @api_url = 'http://reader.flyleaf.me'
    end

    url = URI.parse(@api_url + '/search')
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    booklist = ActiveSupport::JSON.decode(res.body)

    @books = []
    booklist.each do |bookid|
      url = URI.parse(@api_url + '/search/' + bookid)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      bookinfo = ActiveSupport::JSON.decode(res.body)[bookid]
      bookinfo["id"] = bookid
      @books.unshift(bookinfo)
    end

    render :index

  end

  def upload

    require 'net/http'
    require 'securerandom'
    require 'fileutils'

    if Rails.env.development?
      @api_url = 'http://localhost:3001'
    else
      @api_url = 'http://reader.flyleaf.me'
    end


    uploaded_io = params[:epub]
    # uploaded_io.original_filename
    shortened = SecureRandom.urlsafe_base64(4)
    shortened_epub = shortened + '.epub'
    FileUtils.mkdir_p(Rails.root.join('public', '.epub', shortened, 'original'))
    File.open(Rails.root.join('public', '.epub', shortened, 'original', shortened_epub), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    url = URI.parse(@api_url + '/load/' + shortened)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    @book_link = shortened
    @books = []

    render :index

  end

end
