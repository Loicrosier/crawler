class PagesController < ApplicationController

  def show
        @page = Page.find(params[:id])
        @errors = []
        @errors_sans_doublons = []
        @page.hxerrors.each do |hxerror|
          @errors << hxerror.text
        end
        @page.seoerrors.each do |seoerror|
          @errors << seoerror.text
        end

      @errors.each do |mot|
        if mot.include?("/") || mot.include?("(") || mot.include?("+")
          mot.gsub!("/","")
          mot.gsub!("(", "")
          mot.gsub!(")", "")
          mot.gsub!("+","")
        end
        if @errors.to_s.scan(/#{mot}/).count > 1 == false
          @errors_sans_doublons << mot
        end
      end
  end


  end
