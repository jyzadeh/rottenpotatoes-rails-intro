class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.uniq.pluck(:rating)#ratings arr
    #ratings
    @selected_ratings = []
    @sort             = ""
    redirect          = false


    
    if(params[:ratings])
      params[:ratings].each {|key, value| @selected_ratings << key}
      session[:ratings] = @selected_ratings
    elsif session[:ratings]
        @selected_ratings = session[:ratings]
        redirect = true
      else
        @selected_ratings = nil
    end

    if params[:sort]
      @sort = params[:sort]
      session[:sort] = @sort
    elsif session[:sort]
      @sort = session[:sort]
      redirect = true
    else
      @sort = nil
    end
    
    #style
      if @sort == 'title'
        @css_title = 'hilite'
      elsif @sort == 'release_date'
        @css_release_date = 'hilite'
      end
    #
    
     if redirect

      redirect_to movies_path :ratings=>@selected_ratings, :sort=>@sort
    else
      @movies = Movie.where(:rating => @selected_ratings).order(@sort)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
