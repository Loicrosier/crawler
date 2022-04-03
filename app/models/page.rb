class Page < ApplicationRecord
  belongs_to :site

HX_ORDER = 1 # Erreur d'ordonancement
HX_DUPLICATE = 2 # Duplicatat de balise <hx> sut le site
HX_DIFF = 3 # </h1> <h3>
PARSER = 4 # Erreur de Nokogiri
TITLE_DUPLICATE = 5 # Duplicatat de titre
IMG_NOALT = 6 # Pas de alt sur une image
TITLE_LENGTH = 7 # Titre trop long
EXTERNAL_FOLLOW = 8 # Lien externe sans nofollow
NO_HREF = 9 # balise <a> sans href
BAD_LINK = 10 # Lien mal formé qui fait planter le parseur uri
DEAD_LINK = 11 # Ein 404
TITLE_WORD_LENGTH = 12 # Titre de moins de 4 mots
TITLE_TOO_SHORT = 13 # Titre de moins de 30 char
TITLE_DUPLICATE = 14 # Un mot du titre se retrouve dans les balises
HX_LENGTH = 15 # Contenu suppérieur à 70 char
META_LENGTH = 16 # Contenu des meta descriptions moins de 70 ou plus de 150
DUPLICATE = 17 # Duplication titre balises.
IMG_ALTLENGTH = 18 # Alt > 100
BALISE_UNCLOSED = 19 #Une balise pas fermée
CANONICAL = 20 #Pas de link canonical sur une page mobile
IMG_WITH_UNDERSCORE = 21 # Liens images avec underscore
LINK_WITH_UNDERSCORE = 22 # liens normaux avec underscore
end
