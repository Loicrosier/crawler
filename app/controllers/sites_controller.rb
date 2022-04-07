class SitesController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'net/http'
  require 'mechanize'
  require 'anemone'

  # FONCTION pour recuperer les urls (crawl sans url sitemap)
  def get_urls(site)
  # site = url du site
  links = []
      if check_sitemap_link(site) != 'good'
        # recupere les liens du site avec mechanize si Nokogiri error

        # recupere les liens du site avec mechanize
        agent = Mechanize.new
        page = agent.get(site)
        page.css("a").each { |link| links << link['href'] }

        # recupere les liens du site avec Anemone
        Anemone.crawl(site) do |anemone|
          anemone.on_every_page do |page|
            page.links.each do |link|
              links << link.to_s
            end
          end
        end


        links.uniq!
        links.reject! { |link| link.nil? || (!link.start_with?(site) || !link.start_with?("./")) }
      else # si le site est good avec nokogiri
            # recupere les liens du site avec anemone
          Anemone.crawl(site) do |anemone|
            anemone.on_every_page do |page|
                page.links.each do |link|
                  links << link.to_s
                end
            end
          end

          # recupere les liens du site avec nokogiri
          doc = Nokogiri::HTML(URI.open(site))
          doc.css('a').each { |link| links << link['href'] }

          # recupere les liens du site avec mechanize
          agent = Mechanize.new
          page = agent.get(site)
          page.css("a").each { |link| links << link['href'] }

          # trie du tableau des liens
          links.uniq!
          links.reject! { |link| link.nil? || (!link.start_with?(site) && !link.start_with?("./")) }
      end

      return links
  end

  ###################################### TOUTES LES FONCTION CRAWL 1 55 A 202 ######################################################
  def check_meta_title(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    if !doc.title.nil?
      if doc.title.size > 60
        Seoerror.create(page_id: page.id, text: "meta title trop long (+60 char)")
      end
    else
      Seoerror.create(page_id: page.id, text: "pas de meta title")
    end
  end
###############################################################################
  def check_meta_description(id)
    page = Page.find_by(id: id)

    if !page.meta_description.blank? # si blanc alors pas de meta description
      if page.meta_description.size > 150
        Seoerror.create(page_id: page.id, text: "meta trop long")
      elsif page.meta_description.size < 70
        Seoerror.create(page_id: page.id, text: "meta trop court")
      end
    else # pas de meta description
      Seoerror.create(page_id: page.id, text: "pas de meta description")
    end
  end

  ###############################################################################
  # fonction pour comparer 2mots dans un tableau
  def check_word(tableau, page_id)
    tableau.each do |mot|
      if tableau.to_s.scan(/#{mot}/).count > 1
        Hxerror.create(page_id: page_id, text: "doublon: #{mot}")
      end
    end
  end

###############################################################################
  def check_title(url, page)
    # ( page = id de la page )
    error_title_count = 0
    title = []
    page = Page.find_by(id: page)
    doc = Nokogiri::HTML(URI.open(url))
    if doc.css('h1').size > 0
      title << "H1" + doc.search('h1').text
    end
    if doc.css('h2').size > 0
      title << "H2" + doc.search('h2').text
    end
    if doc.css('h3').size > 0
    title << doc.search('h3').text
    end
    if doc.css('h4').size > 0
      title << doc.search('h4').text
    end
    if doc.css('h5').size > 0
      title << doc.search('h5').text
    end
    if doc.css('h6').size > 0
      title << doc.search('h6').text
    end
    # verif balise h1 double
    if doc.css('h1').size > 1
      Seoerror.create(page_id: page.id, text: "h1 double")
    end

   # verif titre doublon
   check_word(title, page.id)

    # verif taille
    title.each do |t|
      if t.length > 70
        Hxerror.create(page_id: page.id, text: "HX trop long")
      end
      # verif si la taille des mots dans le titre es plus grand que 4
      if t.scan(/\w+/).size < 4
       Hxerror.create(page_id: page.id, text: "Le nombre de mot d'un des titres est trop court")
      end
      # verif si le titre est trop court
      if t.size < 30
        error_title_count += 1
        Hxerror.create(page_id: page.id, text: "nombre de Titre trop court: #{error_title_count} (-de 30 Char)")
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
            Seoerror.create(ligne: a.line, text: a["href"].to_s.force_encoding("utf-8")[0..254], page_id: page.id )
            next
          end
          if (!(a["href"].start_with? "./") && !(dst.to_s.include? hst.to_s) && !(dst.host.nil?)) && (!a["rel"] || !a["rel"].include?("nofollow"))
            Seoerror.create(page_id: page.id, text: "lien externe avec rel nofollow (#{a["href"]})", ligne: a.line)
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
     redirect_to site_path(@site.id), notice: "Site créé avec succès"
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

  def destroy
    @site = Site.find(params[:id])
    @site.destroy
    redirect_to sites_path, notice: "Site supprimé avec succès"
  end
  ###############################################################
  # fonction qui appelle le crawl
  def crawl
    @site = Site.find(params[:id])
    url = @site.url
    lien = get_urls(url)
    # iterer sur chaque lien pour cree les pages du site
    lien.each do |link|
      if link.start_with?('./')
        link = url + link.gsub!('./', '/')
      end
      Page.where(url: link).destroy_all
      next if check_sitemap_link(link) != 'good'
       doc = Nokogiri::HTML(URI.open(link))
      meta_desc = doc.css('meta[name="description"]').text
      Page.create(url: link, site_id: @site.id, content: doc.content.to_s, meta_description: meta_desc)
    end
    # recup des pages du site
    @pages = Page.where(site_id: @site.id)

    @pages.each do |page|
      page.seoerrors.destroy_all
      page.hxerrors.destroy_all
      check_meta_title(page.id)
      check_meta_description(page.id)
      check_title(page.url, page.id)
      check_img(page.id)
      check_canonical(page.id)
      check_div(page.id)
    end

    redirect_to site_path(@site), notice: "Site crawlé avec succès"

  end
  ###############################################################################
def check_sitemap_link(url)
  begin
    document = Nokogiri::XML(URI.open(url))
    'good'
  rescue Exception => e
    e.message
  end
end



# recupere les lien dans le xml en fonction de leur format
def get_links_sitemap(site)
  # site = url du site
  # url_in = url dans le xml
        link_sitemap = []
        # verif si le lien de sitemap.xml existe sinon change
      if check_sitemap_link(site) == 'good'
        #### travail xml #####
        document = Nokogiri::XML(URI.open(site))

        # si les liens sont normaux
       document.to_s.scan(/<loc>(.*?)<\/loc>/).each do |url_in|
          if url_in[0].start_with?("h") && url_in[0].end_with?(".html")
            link_sitemap << url_in[0]
          end
          # si les liens recu commence par <CDATA ext
          if url_in[0].start_with?("<![CDATA[") && url_in[0].end_with?("]]>")
            url = url_in[0].gsub!("<![CDATA[","")
            url = url.gsub!("]]>","")
            link_sitemap << url
          end
          # verif si les liens du site map sont des xml change de chemin
          if url_in[0].end_with?(".xml")
           url_sitemap = site.gsub!("sitemap.xml","page-sitemap.xml")
            if check_sitemap_link(url_sitemap) == 'good'
              link_sitemap << get_links_sitemap(url_sitemap)
            end
          end
        end

      else # else du si la page sitemap n'est pas good
        url_sitemap = site.gsub!("sitemap.xml","page-sitemap.xml")
        if check_sitemap_link(url_sitemap) == 'good'
          link_sitemap << get_links_sitemap(url_sitemap)
        end
      end

    return link_sitemap
 end
 ###########################################################################################
# fonction pour recuperer les lien (fonction qui appelle les autres fonctions)
def lunch_link_sitemap(url)
      urls = []
      if check_sitemap_link(url) == 'good'
        urls << get_links_sitemap(url)
      else
        # si la requete es pas bonne
        # et que l'url fini par page-sitemap.xml on remplace et reessaye
        if url.end_with?("page-sitemap.xml")
          good_url = url.gsub!("page-sitemap.xml","sitemap.xml")
          urls << get_links_sitemap(good_url)
        end
      end
      return urls.flatten!
end



# recupere les lien dans le xml en fonction de leur format
def get_links_sitemap(site)
  # site = url du site
  # url_in = url dans le xml
        link_sitemap = []
        # verif si le lien de sitemap.xml existe sinon change
      if check_sitemap_link(site) == 'good'
        #### travail xml #####
        document = Nokogiri::XML(URI.open(site))

        # si les liens sont normaux
       document.to_s.scan(/<loc>(.*?)<\/loc>/).each do |url_in|
          if url_in[0].start_with?("h") && url_in[0].end_with?(".html")
            link_sitemap << url_in[0]
          end
          # si les liens recu commence par <CDATA ext
          if url_in[0].start_with?("<![CDATA[") && url_in[0].end_with?("]]>")
            url = url_in[0].gsub!("<![CDATA[","")
            url = url.gsub!("]]>","")
            link_sitemap << url
          end
          # verif si les liens du site map sont des xml change de chemin
          if url_in[0].end_with?(".xml")
           url_sitemap = site.gsub!("sitemap.xml","page-sitemap.xml")
            if check_sitemap_link(url_sitemap) == 'good'
              link_sitemap << get_links_sitemap(url_sitemap)
            end
          end
        end

      else # else du si la page sitemap n'est pas good
        url_sitemap = site.gsub!("sitemap.xml","page-sitemap.xml")
        if check_sitemap_link(url_sitemap) == 'good'
          link_sitemap << get_links_sitemap(url_sitemap)
        end
      end

    return link_sitemap
 end
 ###########################################################################################
# fonction pour recuperer les lien (fonction qui appelle les autres fonctions)
# def lunch_link_sitemap(url)
#       urls = []
#       # si url du si es bonne
#         urls << get_links_sitemap(url)
#         # si la requete es pas bonne
#         # et que l'url fini par page-sitemap.xml on remplace et reessay
#       return urls.flatten!
#     end

###############################################################################################

# fonction qui fais le sitemap
def sitemap
  lien_sitemap = []
  @site = Site.find(params[:id])
  # construction de l'url du sitemap
  if @site.url.end_with?("/")
    url = @site.url + "sitemap.xml"
  else
    url = @site.url + "/sitemap.xml"
  end

  # recup les lien du sitemap
    lien_sitemap << lunch_link_sitemap(url)

    lien_sitemap.uniq!

  lien_sitemap.flatten.each do |lien|
      Page.where(url: lien).destroy_all
      doc = Nokogiri::HTML(URI.open(lien))
      meta_desc = doc.css('meta[name="description"]').text
      Page.create(url: lien, site_id: @site.id, content: doc.content.to_s, meta_description: meta_desc)
  end

    @pages = Page.where(site_id: @site.id)

    @pages.each do |page|
      page.seoerrors.destroy_all
      page.hxerrors.destroy_all
      check_meta_title(page.id)
      check_meta_description(page.id)
      check_title(page.url, page.id)
      check_img(page.id)
      check_canonical(page.id)
      check_div(page.id)
    end

    redirect_to site_path(@site), notice: "url sitemap crawlé avec succès"
end

########################################################################

  private

  def site_params
    params.require(:site).permit(:name, :url)
  end
end


# finir d'implementer checktitlesizeetcreelestitles
