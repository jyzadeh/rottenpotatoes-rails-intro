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
    @movies = Movie.all
    @selectedRatings = {}
    @all_ratings = ['G','PG','PG-13','R', 'NC-17']
    @requiresRedirect = false

    @all_ratings.each { |rating|
      if params[:ratings]
        @selectedRatings[rating] = params[:ratings].has_key?(rating)
      else
        @selectedRatings[rating] = false
      end
    }
    

    @movies = @movies.find_all{|m| @selectedRatings[m.rating]}
    
    if params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings]
      params[:ratings] = session[:ratings]
      @requiresRedirect = true
    end
    
    if params[:sort] == 'title'
      session[:sort] = params[:sort]
      @movies = @movies.sort_by{|m| m.title}
    elsif params[:sort] == 'date'
      session[:sort] = params[:sort]
      @movies = @movies.sort_by{|m| m.release_date}
    elsif session[:sort]
      params[:sort] = session[:sort]
      @requiresRedirect = true
    end
    
    if @requiresRedirect
      redirect_to movies_path(:sort=>params[:sort], :ratings =>params[:ratings])
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
