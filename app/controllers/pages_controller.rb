class PagesController < ApplicationController

  def show
        @page = Page.find(params[:id])
        @site = @page.site
        @errors = []
        @page.hxerrors.each do |hxerror|
          @errors << hxerror.text
        end
        @page.seoerrors.each do |seoerror|
          @errors << seoerror.text
        end
  end

  def compte_rendu
    @page = Page.find(params[:id])
    # @erreur_seo = Seoerror.where(page_id: @page.id)
    # @erreur_hx = Hxerror.where(page_id: @page.id)

    respond_to do |format|
      format.html # rien
      format.json { render json: erreur }
    end
  end

  def erreur
    {
      seo: "Seoerror.where(page_id: @page.id)",
      hxerror: "Hxerror.where(page_id: @page.id)"
    }
  end

  end
