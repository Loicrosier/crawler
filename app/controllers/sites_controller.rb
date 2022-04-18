class SitesController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'net/http'
  require 'mechanize'
  require 'anemone'

  # FONCTION pour recuperer les urls (crawl sans url sitemap)
def get_urls(site)

 link_crawl = []
  if check_sitemap_link(site) != 'good'

    Anemone.crawl(site) do |anemone|
      anemone.on_every_page do |page|
        page.links.each do |link|
          link_crawl << link.to_s
        end
      end
    end
    agent = Mechanize.new
    page = agent.get(site)
    page.css("a").each { |link| link_crawl << link['href'] }
    else
      doc = Nokogiri::HTML(URI.open(site))
      doc.css('a').each do |link|
        link_crawl << link[:href]
      end
      Anemone.crawl(site) do |anemone|
        anemone.on_every_page do |page|
          page.links.each do |link|
            link_crawl << link.to_s
          end
        end
      end

    agent = Mechanize.new
    page = agent.get(site)
    page.links.each do |link|
      link_crawl << link.to_s
    end
  end



  link_crawl.uniq!
  link_crawl.reject! { |link| link.nil? || (!link.start_with?(site) && !link.start_with?('./')) || link.end_with?('.pdf') }


  return link_crawl
end

  ###################################### TOUTES LES FONCTION CRAWL 1 55 A 202 ######################################################
  def check_meta_title(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    if !doc.title.nil?
      if decode_utf(doc.title).size > 60
        Seoerror.create(page_id: page.id, text: "meta title trop long (+60 char) : #{decode_utf(doc.title).size}")
      end
      if decode_utf(doc.title).size < 30
        Seoerror.create(page_id: page.id, text: "meta title trop court (-30 char) : #{decode_utf(doc.title).size}")
      end
    else
      Seoerror.create(page_id: page.id, text: "pas de meta title")
    end
  end
###############################################################################
  def check_meta_description(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    meta_desc = doc.css('meta[name="description"]')
    if !meta_desc.empty?
      meta_desc_decoder = decode_utf(meta_desc.first['content'])

      if !meta_desc_decoder.empty?
        if meta_desc_decoder.size > 155
          Seoerror.create(page_id: page.id, text: "meta description trop longue (+155 char) : #{meta_desc_decoder.size}")
        end
        if meta_desc_decoder.size < 70
          Seoerror.create(page_id: page.id, text: "meta description trop courte (-70 char) : #{meta_desc_decoder.size}")
        end
      else # si le tableau est vide
        Seoerror.create(page_id: page.id, text: "pas de meta description")
      end

    end
  end

  ###############################################################################
  # fonction pour comparer 2mots dans un tableau
  def check_word(tableau, page_id)
    tableau.each do |mot|
      if tableau.count(mot) > 1
        Hxerror.create(page_id: page_id, text: "TITRES DUPLIQUER : #{mot}")
      end
    end
  end

  ###############################################################################
  # fonction pour remettre les phrases a la normal
  def decode_utf(mot)
  mot.gsub!("Ã©", "é")
  mot.gsub!("Ã¨", "è")
  mot.gsub!("Ãª", "ê")
  mot.gsub!("Ã«", "ë")
  mot.gsub!("Ã¢", "â")
  mot.gsub!("Ã§", "ç")
  mot.gsub!("Ã®", "î")
  mot.gsub!("Ã´", "ô")
  mot.gsub!("Ã¹", "ù")
  mot.gsub!("Ã¼", "ü")
  mot.gsub!("Ã»", "û")
  mot.gsub!("Ã¤", "ä")
  mot.gsub!("Ã¶", "ö")
  mot.gsub!("Â°", "°")
  mot.gsub!("Ã", "É")
  mot.gsub!("Ã", "È")
  mot.gsub!("Ã", "Ê")
  mot.gsub!("Ã«", "Ë")
  mot.gsub!("Ã¢", "Â")
  mot.gsub!("Ã®", "Î")
  mot.gsub!("", "'")
  mot.gsub!("'", " ")
  mot.gsub!("â\u0082¬", "$")
  mot.gsub!("Ã ", "à")
  mot.gsub!("â\u0080\u0093", "-")
  mot.gsub!("â'", "'")
  return mot
end

###############################################################################
  def check_title(url, page)
    # ( page = id de la page )
    error_title_count = 0
    title = []
    page = Page.find_by(id: page)
    doc = Nokogiri::HTML(URI.open(url))
    doc.css('h1').each {|h1| title << "H1" + decode_utf(h1.text) } unless doc.css('h1').nil? || doc.css('h1') == ""
    doc.css('h2').each {|h2| title << "H2" + decode_utf(h2.text) } unless doc.css('h2').nil? || doc.css('h2') == ""
    doc.css('h3').each {|h3| title << "H3" + decode_utf(h3.text) } unless doc.css('h3').nil? || doc.css('h3') == ""
    doc.css('h4').each {|h4| title << "H4" + decode_utf(h4.text) } unless doc.css('h4').nil? || doc.css('h4') == ""
    doc.css('h5').each {|h5| title << "H5" + decode_utf(h5.text) } unless doc.css('h5').nil? || doc.css('h5') == ""
    doc.css('h6').each {|h6| title << "H6" + decode_utf(h6.text) } unless doc.css('h6').nil? || doc.css('h6') == ""

    # p title
    # verif balise h1 double
    if doc.css('h1').size > 1
      Seoerror.create(page_id: page.id, text: "h1 double")
    end
    # title for check = (enleve les H1 ext devant pour compter le bon nombres de titres ext)
    # title.each do |word|
    #   word.gsub("H1", "") || word.gsub("H2","")
    #   word.gsub("H3", "") || word.gsub("H4", "")
    #   word.gsub("H5", "") || word.gsub("H6", "")
    #   title_for_check << word
    # end

    # verif titre doublon
    check_word(title, page.id)

    # les - 2 pour ne pas compter les H? devant

    title.each do |t|
      if t.size - 2 > 70
        Hxerror.create(page_id: page.id, text: "HX avec trop de char (+70): #{t}")
      end
      # verif si la taille des mots dans le titre es plus grand que 4

      # verif si le titre est trop court
      # if t.size - 2 < 30
      #   error_title_count += 1
      #   Hxerror.create(page_id: page.id, text: "titres moins de 30 Char:  #{t} (taille: #{t.size - 2})")
      # end
    end
  end
  ############################################################


  def check_img(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    doc.css('img').each do |img|
      if img[:alt] == "" && img[:src].start_with?("https") || img[:src].start_with?("http")
        Seoerror.create( page_id: page.id, text: "pas d'alt sur l'image : " + img[:src])
      elsif img[:alt].size > 125
        Seoerror.create( page_id: page.id, text: "alt de l'image trop longue sur: " + img[:src])
      end
    end
  end
###############################################################################

  def check_canonical(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    if doc.css('link[rel="canonical"]').size < 1
      Seoerror.create(page_id: page.id, text: "pas de canonical")
    end
  end
###############################################################################

  def check_url(id)
      page = Page.find_by(id: id)
      doc = Nokogiri::HTML(URI.open(page.url))
      doc.css('a').each do |link|
          if !link[:href].nil?
            if link[:href].include?('_')
              Seoerror.create(page_id: page.id, text: "lien avec underscore (#{link[:href]})")
            end
          end
      end

      doc.css('img').each do |link|
        if link[:src].include?('_')
          Seoerror.create( ligne: link.line, page_id: page.id, text: "image avec underscore #{link[:src]}")
        end
      end


  end
###############################################################################
  def check_div(id)
    page = Page.find_by(id: id)
    doc = Nokogiri::HTML(URI.open(page.url))
    div_count = 0
    doc = doc.search("//div")
    if (doc != nil)
      total_doc = doc[0].to_s
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
      redirect_to site_new_path, notice: "Erreur lors de la création du site (#{@site.errors.full_messages})"
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
    @site.last_crawl = Time.now
    @site.last_crawl_mode = "crawl sans sitemap url"
    @site.save

    url = @site.url
    lien = get_urls(url)
    # iterer sur chaque lien pour cree les pages du site
     Page.where(site_id: @site.id).destroy_all
    lien.each do |link|
      if link.start_with?('./')
        link = url + link.gsub!('./', '/')
      end
      next if check_sitemap_link(link) != 'good'
       doc = Nokogiri::HTML(URI.open(link))
      meta_desc = doc.css('meta[name="description"]').text
      Page.create(url: link, site_id: @site.id, content: doc.content.to_s, meta_description: meta_desc)
    end
    # recup des pages du site
    @pages = Page.where(site_id: @site.id)
    # save du nombre de page crawlé
    @site.page_count_crawl = @pages.count
    @site.save

    @pages.each do |page|
      page.seoerrors.destroy_all
      page.hxerrors.destroy_all
      check_meta_title(page.id)
      check_meta_description(page.id)
      check_title(page.url, page.id)
      check_img(page.id)
      check_canonical(page.id)
      check_div(page.id)
      check_url(page.id)
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

 ###########################################################################################
# fonction pour recuperer les lien (fonction qui appelle les autres fonctions)
def lunch_link_sitemap(url_sitemap, url_du_site)
      urls = []
      if check_sitemap_link(url_sitemap) == 'good'
        urls << get_links_sitemap(url_sitemap, url_du_site)
      else
        # si la requete es pas bonne
        # et que l'url fini par page-sitemap.xml on remplace et reessaye
        if url_sitemap.end_with?("sitemap.xml")
          good_url = url_sitemap.gsub!("sitemap.xml", "page-sitemap.xml")
          urls << get_links_sitemap(good_url, url_du_site)
        end
      end
  return urls.flatten!
end



# recupere les lien dans le xml en fonction de leur format
    def re_test(url_sitemap, url_du_site)
      doc = Nokogiri::XML(URI.open(url_sitemap))
      link_sitemap = []
        doc.to_s.scan(/<loc>(.*?)<\/loc>/).each do |url_in|
            if url_in.first.start_with?(url_du_site) && (url_in.first.end_with?("/") || url_in.first.end_with?('.html') )
              link_sitemap << url_in.first
            end

            if url_in.first.start_with?("<![CDATA[") && url_in[0].end_with?("]]>")
              url = url_in[0].gsub!("<![CDATA[","")
              url = url.gsub!("]]>","")
              link_sitemap << url_in.first
            end

        end
        return link_sitemap.flatten
    end


  def get_links_sitemap(url_sitemap, url_du_site)
    link_sitemap = []
    doc = Nokogiri::XML(URI.open(url_sitemap))
    if doc.to_s.scan(/<loc>(.*?)<\/loc>/).first[0].end_with?(".xml")
      url_sitemap.gsub!("sitemap.xml", "page-sitemap.xml")
      if check_sitemap_link(url_sitemap) == 'good'
        link_sitemap << re_test(url_sitemap, url_du_site)
      end
    else

      doc.to_s.scan(/<loc>(.*?)<\/loc>/).each do |url_in|
          if url_in.first.start_with?(url_du_site) && (url_in.first.end_with?("/") || url_in.first.end_with?('.html') )
            link_sitemap << url_in.first
          end

          if url_in.first.start_with?("<![CDATA[") && url_in[0].end_with?("]]>")
            url = url_in[0].gsub!("<![CDATA[","")
            url = url.gsub!("]]>","")
            link_sitemap << url_in.first
          end

      end
    end

    return link_sitemap.flatten
  end

###############################################################################################

# fonction qui fais le sitemap
def sitemap
  lien_sitemap = []
  @site = Site.find(params[:id])
  @site.last_crawl = Time.now
  @site.last_crawl_mode = "sitemap"
  @site.save
  # construction de l'url du sitemap
  if @site.url.end_with?("/")
    url_sitemap = @site.url + "sitemap.xml"
  else
    url_sitemap = @site.url + "/sitemap.xml"
  end

  # recup les lien du sitemap
    lien_sitemap << lunch_link_sitemap(url_sitemap, @site.url)

    lien_sitemap.uniq!

  Page.where(site_id: @site.id).destroy_all
  lien_sitemap.flatten.each do |lien|
      doc = Nokogiri::HTML(URI.open(lien))
      meta_desc = doc.css('meta[name="description"]').text
      Page.create(url: lien, site_id: @site.id, content: doc.content.to_s, meta_description: meta_desc)
  end

    @pages = Page.where(site_id: @site.id)
    # save nombre page crawlé avec sitemap
    @site.page_count_sitemap = @pages.count
    @site.save

    @pages.each do |page|
      page.seoerrors.destroy_all
      page.hxerrors.destroy_all
      check_meta_title(page.id)
      check_meta_description(page.id)
      check_title(page.url, page.id)
      check_img(page.id)
      check_canonical(page.id)
      check_div(page.id)
      check_url(page.id)
    end
    redirect_to site_path(@site.id), notice: "url sitemap crawlé avec succès"
end

########################################################################

  private

  def site_params
    params.require(:site).permit(:name, :url)
  end
end


# finir d'implementer checktitlesizeetcreelestitles
