class SitesController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'net/http'
  require 'uri'


  def check_meta_title(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    if doc.title.size > 60
      Seoerror.create(page_id: page.id, text: "meta title trop long (+60 char)")
  end
###############################################################################
  def check_meta_description(id)
    page = Page.find_by(id: id)
    if page.meta_description.size > 150
      Seoerror.create(page_id: page.id, text: "meta trop long")
    elsif page.meta_description.size < 70 && !page.meta_description.blank?
      Seoerror.create(page_id: page.id, text: "meta trop court")
    end
  end
#########################################################################
  def check_title(url, page)
    title = []
    error_title_count = 0

    doc = Nokogiri::HTML(URI.open(url))
    if doc.search('h1').text != "" && doc.search('h1').text != nil
      title << doc.search('h1').text
    end
    if doc.search('h2').text != "" && doc.search('h2').text != nil
      title << doc.search('h2').text
    end
    if doc.search('h3').text != "" && doc.search('h3').text != nil
    title << doc.search('h3').text
    end
    if doc.search('h4').text != "" && doc.search('h4').text != nil
      title << doc.search('h4').text
    end
    if doc.search('h5').text != "" && doc.search('h5').text != nil
      title << doc.search('h5').text
    end
    if doc.search('h6').text != "" && doc.search('h6').text != nil
      title << doc.search('h6').text
    end

    # verif doublon
    if title.uniq! == nil
      "aucun titre double"
    else
       Hxerror.create(page_id: page, text: "HX doubler")
    end
    # verif taille
    title.each do |t|
      if t.length > 70
        Hxerror.create(page_id: page, text: "HX trop long")
      end
      # verif si la taille des mots dans le titre es plus grand que 4
      if t.scan(/\w+/).size < 4
       Hxerror.create(page_id: page, text: "Le nombre de mot d'un des titres est trop court")
      end
      # verif si le titre est trop court
      if t.size < 30
        error_title_count += 1
        Hxerror.create(page_id: page, text: "nombre de Titre trop court: #{error_title_count} (-de 30 Char)")
      end
    end
  end
  ############################################################


  def check_img(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    doc.css('img').each do |img|
      if img[:alt].nil?
        Seoerror.create(page_id: page.id, text: "pas d'alt sur l'image( #{img[:href]}")
      elsif img[:alt].size > 100
        Seoerror.create(page_id: page.id, text: "alt de l'image trop longue ")
      end
    end
  end
###############################################################################

  def check_canonical(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    if doc.css('link[rel="canonical"]').nil?
      Seoerror.create(page_id: page.id, text: "pas de canonical")
    end
  end
###############################################################################

  def check_url(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    doc.css('a').each do |link|
      if link[:href].include?('_')
        Seoerror.create(page_id: page.id, text: "lien avec underscore (#{link[:href]})")
      end

      doc.css('img').each do |img|
        if img[:href].include?('_')
          Seoerror.create(page_id: page.id, text: "lien image avec underscore (#{img[:src]})")
        end
      end
    end

    ## check des nofollow external
    doc.css('a').each do |a|
      begin
         dst = URI.parse(URI.encode(a['href'].to_s))
        rescue
          Seoerror.create(ligne: a.line, text: a["href"].to_s.force_encoding("utf-8")[0..254], page_id: p.id )
          next
        end
        if (!(a["href"].start_with? "./") && !(dst.to_s.include? hst.to_s) && !(dst.host.nil?)) && (!a["rel"] || !a["rel"].include?("nofollow"))
          Seoerror.create(page_id: page.id, text: "lien externe avec rel nofollow (#{a["href"]})", ligne: a.line)
        end
      end
    end
  end
###############################################################################
  def check_div(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    div_count = 0
    tmp = doc.search("//div")
    if (tmp != nil)
      total_doc = tmp[0].to_s
    begin
      div_count = div_count + total_doc.scan(/<div/).count
      div_count = div_count - total_doc.scan(/div>/).count + total_doc.scan(/<div>/).count
      Seoerror.create(page_id: page.id, text: "Il y a une div pas fermée" + div_count.to_s) unless (div_count == 0)
    end
    end
  end


  ####################### CRUD ##############################
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
  ###############################################################
  # fonction for crowling site
  def crawl
    @site = Site.find(params[:id])
    url = @site.url
    lien = []

    doc = Nokogiri::HTML(URI.open(url))
    doc.css('a').each do |link|
      lien << link[:href]
    end

    lien.reject! { |link| link.nil? || link.start_with?('#', "#content", 'mailto:') }

   # iterer sur chaque lien pour cree les pages du site
    lien.each do |link|
        pages = Page.where(url: link).destroy_all
        doc = Nokogiri::HTML(URI.open(link))
        meta_desc = doc.css('meta[name="description"]').text
        Page.create(url: link, site_id: @site.id, content: doc.content.to_s, meta_description: meta_desc)
    end

    @pages = Page.where(site_id: @site.id)

    @pages.each do |page|
      check_meta_title(page.id)
      check_meta_description(page.id)
      check_title(page.url, page.id)
      check_img(page.id)
      check_canonical(page.id)
      check_div(page.id)
    end

  end
###############################################################################
  private

  def site_params
    params.require(:site).permit(:name, :url)
  end
end
