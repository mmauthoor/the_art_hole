require "sinatra"
require "sinatra/reloader"
require "pg"
require "bcrypt"
require "pry"

require_relative "models/artwork.rb"
require_relative "models/user.rb"

# Helper methods required:
# Identify current user
# Check if logged in

enable :sessions

# Ask DT - is it ok to make your homepage different erbs depending on if logged in or not? 
get "/" do
  
  # if not logged in, serve up
  # erb(:index) 
  # unless logged in
  # if logged in, provide main gallery
  result = db_query("SELECT * FROM artworks;")
  # ideally would use openstruct here. 
  erb(:artworks, locals: {
    artworks: result
  })
end

# Routes that will be required:
# Artworks:
# GET /artworks/new - add a new listing
get "/artworks/new" do
  
end

# POST /artworks - send new listing to DB
post "/artworks" do
  
end

# GET /artworks/:id - show individual artwork
get "/artworks/:id" do

  artwork = db_query("SELECT * FROM artworks WHERE id = $1;", [params['id']]).first

  erb(:artwork, locals: {
    artwork: OpenStruct.new(artwork)
  })

end

# DELETE /artworks/:id - delete individual artwork
delete "/artworks/:id" do
  delete_artwork(params["id"])
  
  # ideally would ultimately redirect to user dashboard
  redirect "/"
  
end

# GET /artworks/:id/edit - form to edit an artwork's details
get "/artworks/:id/edit" do
  sql = "SELECT * FROM artworks WHERE id = $1"
  artwork = db_query(sql, [params["id"]]).first

  erb(:edit_artwork, locals: {
    artwork: OpenStruct.new(artwork)
  })
end 

# PUT /artworks/:id - send modified details of an artwork to DB
put "/artworks/:id" do
  update_artwork(params["title"], params["artist"], params["image_url"], params["year"], params["media"], params["description"], params["id"])

  redirect "/artworks/#{params["id"]}"
end

#Users:
# GET /login 
get "/login" do
  erb(:login)
end

# GET /users/new - form for users to provide info to sign up
get "/users/new" do
  erb(:new_user)
end

# POST /users - adding new user to DB
post "/users" do
  
end

# GET /users/:id - show data connected to that user, i.e. listings, watched AW
get "/users/:id" do
  # should only be able to get this if you ARE the user in question
end

# POST /session - to start new session
post "/session" do
  
end

# DELETE /session - to end session
delete "/session" do
  
end






