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
  return mot
end

###############################################################################


def self.check_balise_ordonnancement(id)
page = Page.find_by(id: id)
doc = Nokogiri::HTML(URI.open(page.url))
hash = {}
i = 100 # mis a 100 pour recup tjr 3 integer a la fin du string

good_page = []
regex_1 = "\n"
regex_2 = "> "
h2_i = 0
h3_i = 0
h4_i = 0
h5_i = 0
h6_i = 0
a = doc.to_s.split(regex_1)
a.each { |h| good_page << h.split(regex_2) }

 good_page.flatten.each do |s|
  i += 1
    if s.match(/h1/) && s.match(/<\/h1/)
        hash.merge!(h1: s + i.to_s)
    end

    if s.match(/h2/) && s.match(/<\/h2/)
        h2_i += 1
        hash.merge!("h2#{h2_i}": s + i.to_s)
    end

      if s.match(/h3/) && s.match(/<\/h3/)
        h3_i += 1
        hash.merge!("h3#{h3_i}": s + i.to_s)
      end

    if s.match(/h4/) && s.match(/<\/h4/)
      h4_i += 1
      hash.merge!("h4#{h4_i}": s + i.to_s)
    end

    if s.match(/h5/) && s.match(/<\/h5/)
      h5_i += 1
      hash.merge!("h5#{h5_i}": s + i.to_s)
    end
 end
 hash.sort_by { |k, v| v[v.size - 3] + v[v.size - 2] + v[v.size - 1] }

 # check si le h1 n'est pas en premier de la page
  if !hash.first.to_s.include?("h1")
     Hxerror.create(page_id: page.id, text: "h1 n'est pas la premiere balise H de la page")
  end

 # check de si balise h2 a H4 pas de H3

    all_h2 = hash.select { |k, v| k.to_s.include?("h2") }
    all_h4 = hash.select { |k, v| k.to_s.include?("h4") }

    hash.each do |k, v|
      all_h2.each do |key_H2, h2_value|
        h2_value = h2_value[h2_value.size - 3] + h2_value[h2_value.size - 2] + h2_value[h2_value.size - 1]
        all_h4.each do |key_h4, h4_value|
          h4_value = h4_value[h4_value.size - 3] + h4_value[h4_value.size - 2] + h4_value[h4_value.size - 1]
          entre_balise = []
          range = h2_value..h4_value
          #e = element de range = value entre H2 et H4
          range.each do |e|
            entre_balise << a.key(e) unless a.key(e).nil?
          end
          if !entre_balise.include?(:h3)
            Hxerror.create(page_id: page.id, text: "erreur entre balise H2 (#{h2_value}) et H4 (#{h4_value}) pas de balise H3")
          end
      end
    end
  end

end
end
