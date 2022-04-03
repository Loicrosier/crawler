class SitesController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'net/http'
  require 'uri'

  def check_title(url)

    # finir le test de la balise title et du contenu de la balise title et regler le pb des h nil
    doc = Nokogiri::HTML(URI.open(url))
    if doc.search('h1').text != "" && doc.search('h1').text != nil
      p "1 " + h1 = doc.search('h1').text
    end
    if doc.search('h2').text != "" && doc.search('h2').text != nil
      p "2 " +  h2 = doc.search('h2').text
    end
    if doc.search('h3').text != "" && doc.search('h3').text != nil
    p "3 " + h3 = doc.search('h3').text
    end
    if doc.search('h4').text != "" && doc.search('h4').text != nil
      p "4 " + h4 = doc.search('h4').text
    end
    if doc.search('h5').text != "" && doc.search('h5').text != nil
      p "5 " + h5 = doc.search('h5').text
    end
    if doc.search('h6').text != "" && doc.search('h6').text != nil
      p "6 " + h6 = doc.search('h6').text
    end

    # verifie si un titre es egale a un autre titre
        case
    when h1 == h2 || h1 == h3 || h1 == h4 || h1 == h5 || h1 == h6
      'title duplicate 1'
    when h2 == h3 || h2 == h4 || h2 == h5 || h2 == h6
      'title duplicate 2'
    when h3 == h4 || h3 == h5 || h3 == h6
      'title duplicate 3'
    when h4 == h2 || h4 == h5 || h4 == h6
      'title duplicate 4'
    else
      0
    end

  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)
    if @site.save
     #
    else
      render 'new'
    end
  end

  def show
    @site = Site.find(params[:id])
  end

  def index
    @sites = Site.all
  end

  # fonction for crowling site
  def crawl
    @site = Site.find(params[:id])
    url = @site.url
    lien = []

    doc = Nokogiri::HTML(URI.open(url))
    doc.css('a').each do |link|
      lien << link[:href]
    end

    lien.reject! { |link| link.nil? || link.start_with?('#', "#content")}

   p @title_error = check_title(@site.url)

  end

  private

  def site_params
    params.require(:site).permit(:name, :url)
  end
end
