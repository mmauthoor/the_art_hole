require "sinatra"
require "sinatra/reloader"
require "pg"

get '/' do
  # if not logged in, serve up
  erb :index
  # if logged in, provide main gallery
end

# Routes that will be required:
# Artworks:
# GET /artworks/new - add a new listing
# POST /artworks - send new listing to DB
# GET /artworks/:id - show individual artwork
# DELETE /artworks/:id - delete individual artwork
# GET /artworks/:id/edit - form to edit an artwork's details
# PUT /artworks/:id - send modified details of an artwork to DB

#Users:
# GET /login 
# POST /users - to add new user
# POST /session - to start new session
# DELETE /session - to end session
# /users/:id - show data connected to that user, i.e. listings, watched AW

# Helper methods required:
# Identify current user
# Check if logged in
# CRUD helper methods in models - including database query method

