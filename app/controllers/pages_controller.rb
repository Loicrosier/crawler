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


  end
