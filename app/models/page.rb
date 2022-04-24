class Page < ApplicationRecord
  belongs_to :site
  has_many :hxerrors, dependent: :destroy
  has_many :seoerrors, dependent: :destroy
  has_many :titles, dependent: :destroy

###############################################################################
  # fonction pour remettre les string a la normal
  def self.decode_utf(mot)
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
  mot.gsub!("â ", " ")
  mot.gsub!("&Atilde;&copy;", "é")
  mot.gsub!("&Atilde;&reg;", "®")
  mot.gsub!("&Atilde;&trade;", "™")
  mot.gsub!("&acirc;&#128;&#153;", "'")
  mot.gsub!("\t", "")
  mot.gsub!("\n", "")
  mot.gsub!("\r", "")
  mot.gsub!("\r\n", "")
  mot.gsub!("\n\r", "")
  mot.gsub!("\r\n\r\n", "")
  return mot
end

###############################################################################


def self.check_balise_ordonnancement(id)
  page = Page.find_by(id: id)
  doc = Nokogiri::HTML(URI.open(page.url))
  hash = {}
  i = 1000 # mis a 100 pour recup tjr 3 integer a la fin du string
  erreurs = []
  h1_i = 0
  h2_i = 0
  h3_i = 0
  h4_i = 0
  h5_i = 0
  h6_i = 0
  good_page = doc.to_s.split(/\n/)

  good_page.flatten.each do |s|
    if s.match(/h1/) && s.match(/<\/h1/)
      h1 = doc.css('h1')[h1_i].text unless doc.css('h1')[h1_i].text.nil?
      h1_i += 1
      hash.merge!("h1/ #{h1_i}": i.to_s + "<h1>" + h1 + "</h1>" )
    end

    if s.match(/h2/) && s.match(/<\/h2/)
      h2 = doc.css('h2')[h2_i].text unless doc.css('h2')[h2_i].text.nil?
      h2_i += 1
      hash.merge!("h2/ #{h2_i}": i.to_s + "<h2>" + h2 + "</h2>" )
    end

    if s.match(/h3/) && s.match(/<\/h3/)
      p "h3"
      h3 = doc.css('h3')[h3_i].text unless doc.css('h3')[h3_i].text.nil?
      h3_i += 1
      hash.merge!("h3/ #{h3_i}": i.to_s + "<h3>" + h3 + "</h3>" )
    end

    if s.match(/h4/) && s.match(/<\/h4/)
      p "h4"
      h4 = doc.css('h4')[h4_i].text unless doc.css('h4')[h4_i].text.nil?
      h4_i += 1
      hash.merge!("h4/ #{h4_i}": i.to_s + "<h4>" + h4 + "</h4>" )
    end
    if s.match(/h5/) && s.match(/<\/h5/)
      h5 = doc.css('h5')[h5_i].text unless doc.css('h5')[h5_i].text.nil?
      h5_i += 1
      hash.merge!("h5 #{h5_i}": i.to_s + "<h5>" + h5 + "</h5>" )
    end

    if s.match(/h6/) && s.match(/<\/h6/)
      h6 = doc.css('h6')[h6_i].text unless doc.css('h6')[h6_i].text.nil?
      h6_i += 1
      hash.merge!("h6 #{h6_i}": i.to_s + "<h6>" + h6 + "</h6>" )
    end
    i += 1
  end

  i = 0
    tableau_de_range = []
    ligne_h2 = []
    ligne_h4 = []
    hash_sort_pos = hash.sort_by { |k, v| v[0] + v[1] + v[2] + v[3] } # hash sort by negative value (- a +)

    ######################################### CHECK SI H1 EST PREMIER DE LA PAGE ###############################################
    if !hash_sort_pos.empty? && !hash_sort_pos[0][0].to_s.include?("h1")
      erreurs << "la balise H1 n'est pas la premiere balise de la page"
    end

    ########################### boucle pour recup les lignes et cree les ranges##################################################
    hash_sort_pos.each do |k, v|
      if k.to_s.include?("h2")
        # key_h2 << k.to_s # pour check son num de balise si h21 ou h22 etc
        ligne_h2 <<  v[0] + v[1] + v[2] + v[3] + " #{k.to_s.gsub!(k[0..1], '')}"
      end
      if k.to_s.include?("h4")
        # key_h4 = k.to_s # pour check son num de balise si h41 ou h42 et
        ligne_h4 << v[0] + v[1] + v[2] + v[3] + " #{k.to_s.gsub!(k[0..1], '')}"
      end
    end


    ################################### PARTIE CREATE RANGE ################################################################

    h2_i.times do |i|
      # check si nil et check si ligne balise h2 1 est ligne balise h4 1 exemple
      ligne_h2_split = ligne_h2[i].split unless ligne_h2[i].nil? # pour couper et prendre le dernier pour num de la balise
      ligne_h4_split = ligne_h4[i].split unless ligne_h4[i].nil? # prendre le dernier pour num balise

      if !ligne_h2_split.nil? && !ligne_h4_split.nil?
         if ligne_h2_split.size == 3 && ligne_h4_split.size == 3 && ligne_h2_split.last == ligne_h4_split.last
           h2_suivant = ligne_h2[i + 1].split unless ligne_h2[i + 1].nil? || ligne_h2[i + 1 ] == "/" # ligne h2 suivante pour cree le range de H4 au H2 suivant
           if ligne_h2_split.first.to_i < ligne_h4_split.first.to_i
              tableau_de_range << (ligne_h2_split.first..ligne_h4_split.first) #envoi des ranges dans un tableau range de h2 a h4
              if h2_suivant.first.to_i > ligne_h4_split.first.to_i
                tableau_de_range << (ligne_h4_split.first..h2_suivant.first) #envoi des ranges dans un tableau range de h4 au H2 suivant
              end
            else
              tableau_de_range << (ligne_h4_split.first..ligne_h2_split.first) #envoi des ranges dans un tableau range de h2 a h4
            end
         end
      end
    end

    ################################## PARTIE CHECK RANGE ##############################################################
    ## boucle pour recup toutesles balises entre h2 et h4 de chaque h2 et h4 et check le contenu entre##############################
    balise_in_range = [] # tableau pour stocker les balises qui sont entre les ranges POS de h2 a h4

    tableau_de_range.each do |ligne| # range de h2 a h4
      check_hash_ligne = hash.transform_values.with_index {|v, i| v[0] + v[1] + v[2] + v[3] }
      hash_check = check_hash_ligne.sort_by { |k, v| v }.to_h # hash sort by negative value (- a +) avec value que la ligne hash a les values entiers
      # pour recup les balises dans les ranges .key(ligne) pour recup la key depuis la valeur
      balise_in_range << hash_check.key(ligne.first)
      balise_in_range << hash_check.key(ligne)
      balise_in_range << hash_check.key(ligne.last)
      balise_in_range.reject! { |balise| balise.nil? }
      balise_in_range.uniq!
      first_balise_in_range = balise_in_range[1].to_s # 1 parce que la premiere balise est la balise de laquelle elle part
      if hash_check.key(ligne.first).to_s[0..1] == "h2"
          if first_balise_in_range[0..1] == "h4"
            value_first = hash[hash_check.key(ligne.first)]
            value_last = hash[hash_check.key(ligne.last)]

            erreurs << "erreur DE BALISE #{hash_check.key(ligne.first).to_s} : (#{decode_utf(value_first).gsub!(value_first[0..3], "")}) A #{hash_check.key(ligne.last).to_s} : (#{decode_utf(value_last).gsub!(value_last[0..3], "")}) pas de balise H3 "
          end
      elsif hash_check.key(ligne.first).to_s[0..1] == "h4"
          if first_balise_in_range[0..1] == "h2"
            value_first = hash[hash_check.key(ligne.first)]
            value_last = hash[hash_check.key(ligne.last)]

            erreurs << "erreur DE BALISE #{hash_check.key(ligne.first).to_s} : (#{decode_utf(value_first).gsub!(value_first[0..3], "")}) A #{hash_check.key(ligne.last).to_s} : (#{decode_utf(value_last).gsub!(value_last[0..3], "")}) pas de balise H3 "
          end
      end

    end
    erreurs.each {|e| Hxerror.create(page_id: page.id, text: e) }
  end



end # end class
