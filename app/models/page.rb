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
      balise_H1 = []
      balise_H2 = []
      balise_H3 = []
      balise_H4 = []
      balise_H5 = []
      balise_H6 = []
      i = 0
      doc.to_s.each_line('br', chomp: true) do |s|
          i += 1
          s.scan(/<h1>(.*?)<\/h1>/).flatten.each { |h1| balise_H1 << h1 + "  (ligne:  " + i.to_s + ")" }
          s.scan(/<h2>(.*?)<\/h2>/).flatten.each { |h2| balise_H2 << h2 + "  (ligne:  " + i.to_s + ")" }
          s.scan(/<h3>(.*?)<\/h3>/).flatten.each { |h3| balise_H3 << h3 + "  (ligne:  " + i.to_s + ")" }
          s.scan(/<h4>(.*?)<\/h4>/).flatten.each { |h4| balise_H4 << h4 + "  (ligne:  " + i.to_s + ")" }
          s.scan(/<h5>(.*?)<\/h5>/).flatten.each { |h5| balise_H5 << h5 + "  (ligne:  " + i.to_s + ")" }
          s.scan(/<h6>(.*?)<\/h6>/).flatten.each { |h6| balise_H6 << h6 + "  (ligne:  " + i.to_s + ")" }
      end
      balise_H2.each do |h2|
        ligne_h2 = h2[h2.size - 3] + h2[h2.size - 2]
        balise_H1.each do |h1|
          ligne_h1 = h1[h1.size - 3] + h1[h1.size - 2]
          p h1
          if ligne_h1.to_i > ligne_h2.to_i
            Hxerror.create(page_id: page.id, text: "ERREUR BALISE H2 : #{decode_utf(h2.gsub(h2.last(12), ""))} DEVANT BALISE H1 #{decode_utf(h1.gsub(h1.last(12), ""))}")
          end
        end
      end
      balise_H3.each do |h3|
        ligne_h3 = h3[h3.size - 3] + h3[h3.size - 2]
        balise_H2.each do |h2|
          ligne_h2 = h2[h2.size - 3] + h2[h2.size - 2]
          if ligne_h2.to_i > ligne_h3.to_i
           Hxerror.create(page_id: page.id, text: "ERREUR BALISE H3 : #{decode_utf(h3.gsub(h3.last(12), ""))} DEVANT BALISE H2 #{decode_utf(h2.gsub(h2.last(12), ""))}")
          end
        end
      end
      balise_H4.each do |h4|
        ligne_h4 = h4[h4.size - 3] + h4[h4.size - 2]
        balise_H3.each do |h3|
          ligne_h3 = h3[h3.size - 3] + h3[h3.size - 2]
          if ligne_h3.to_i > ligne_h4.to_i
            Hxerror.create(page_id: page.id, text: "ERREUR BALISE H4 : #{decode_utf(h4.gsub(h4.last(12), ""))} DEVANT BALISE H3 #{decode_utf(h3.gsub(h3.last(12), ""))}")
          end
        end
      end
      balise_H5.each do |h5|
        ligne_h5 = h5[h5.size - 3] + h5[h5.size - 2]
        balise_H4.each do |h4|
          ligne_h4 = h4[h4.size - 3] + h4[h4.size - 2]
          if ligne_h4.to_i > ligne_h5.to_i
            Hxerror.create(page_id: page.id, text: "ERREUR BALISE H5 : #{decode_utf(h5.gsub(h2.last(12), ""))} DEVANT BALISE H4 #{decode_utf(h4.gsub(h4.last(12), ""))}")
          end
        end
      end
      balise_H6.each do |h6|
        ligne_h6 = h6[h6.size - 3] + h6[h6.size - 2]
        balise_H5.each do |h5|
          ligne_h5 = h5[h5.size - 3] + h5[h5.size - 2]
          if ligne_h5.to_i > ligne_h6.to_i
            Hxerror.create(page_id: page.id, text: "ERREUR BALISE H6 : #{decode_utf(h6.gsub(h6.last(12), ""))} DEVANT BALISE H5 #{decode_utf(h5.gsub(h5.last(12), ""))}")
          end
        end
      end

  end
end
