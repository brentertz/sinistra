# app.rb - start with: ruby app.rb OR rackup -p 4567 OR shotgun config.ru -p 4567 (if you want code auto-reloading)
require 'rubygems'
require 'compass' # must be loaded before sinatra
require 'sinatra'
require './partials'
require 'haml' # must be loaded after sinatra

module Sinistra
  class App < Sinatra::Base
    # Set Sinatra Variables
    set :app_file, __FILE__
    
    # Generic Helpers
    helpers Sinatra::Partials
    helpers do
      # Sinatra stores sass files in the views dir, but I prefer to store them elsewhere
      def scss(template, *args)
        template = :"#{settings.sass_dir}/#{template}" if template.is_a? Symbol
          super(template, *args)
      end
    end

    # Configuration
    configure do
      Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
      set :sass, Compass.sass_engine_options
      set :sass_dir, '../public/stylesheets/sass'
      set :haml, :format => :html5 # default Haml format is :xhtml  
    end
    configure :production, :test do
    end

    # Handle stylesheet requests
    get '/stylesheets/:name.css' do
      content_type 'text/css', :charset => 'utf-8'
      scss(:"#{params[:name]}", Compass.sass_engine_options)
    end

    # Home page
    get '/' do
      haml :index, :layout => !request.xhr?
    end  

    # Error handlers
    not_found do
      "I'm not sure what you are looking for, but I can tell you that it isn't here."
    end
    error do
      'Sorry there was a nasty error - ' + env['sinatra.error'].name
    end
    
    # Start the server if ruby file executed directly
    run! if app_file == $0    
  end
end