class ThemesController < ApplicationController
  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(permitted_params.theme)
    if @theme.save
      redirect_to @theme, notice: t(:'Theme created')
    else
      render :new
    end
  end

  def show
    load_theme
  end

  def edit
    load_theme
  end

  def update
    load_theme
    if @theme.update_attributes(permitted_params.theme)
      redirect_to @theme, notice: t(:'Theme updated')
    else
      render :edit
    end
  end

  private
  def load_theme
    @theme = Theme.find(params[:id])
  end
end
