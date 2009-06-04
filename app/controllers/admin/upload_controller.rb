class Admin::UploadController < ApplicationController
  before_filter :authenticate

  def index
    new
    render :action => 'new'
  end

  def new
    @endnote = Endnote.new
  end

  def create
    @endnote = Endnote.new(:uploaded_data => params[:endnote_file], :uploaded_by => session[:user][:id])

    if @endnote.save
      flash[:notice] = 'Endnote file was successfully uploaded.'
      redirect_to(:controller => 'home')
    else
      render :action => :new
    end
  end
end
