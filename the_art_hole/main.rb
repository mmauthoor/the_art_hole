require "sinatra"
require "sinatra/reloader"
require "pg"
require "bcrypt"
require "pry"

require_relative "models/artwork.rb"
require_relative "models/user.rb"

enable :sessions

def logged_in?()
  if session[:user_id]
      return true
  else
      return false
  end
end

def current_user()
  sql = "SELECT * FROM users WHERE id = #{session[:user_id]};"
  user = db_query(sql).first
  return OpenStruct.new(user)
end

# Ask DT - is it ok to make your homepage different erbs depending on if logged in or not? 
get "/" do
  if logged_in?
    result = db_query("SELECT * FROM artworks;")
    # ideally would use openstruct on results - maybe in artworks erb? 
    erb(:artworks, locals: {
      artworks: result
    })
  else
    # not sure if this will work
    erb(:index, :layout => false)
  end 
end

get "/artworks/new" do
  erb(:new_artwork)  
end

post "/artworks" do
  redirect "/login" unless logged_in?

  create_artwork(params["title"], params["artist"], params["image_url"], params["year"], params["media"], params["description"], current_user.id)
  redirect "/users/#{current_user.id}"
end

get "/artworks/:id" do
  artwork = db_query("SELECT * FROM artworks WHERE id = $1;", [params['id']]).first

  erb(:artwork, locals: {
    artwork: OpenStruct.new(artwork)
  })
end

delete "/artworks/:id" do
  delete_artwork(params["id"])
  
  redirect "/users/#{current_user.id}"
end

get "/artworks/:id/edit" do
  sql = "SELECT * FROM artworks WHERE id = $1"
  artwork = db_query(sql, [params["id"]]).first

  erb(:edit_artwork, locals: {
    artwork: OpenStruct.new(artwork)
  })
end 

put "/artworks/:id" do
  update_artwork(params["title"], params["artist"], params["image_url"], params["year"], params["media"], params["description"], params["id"])

  redirect "/artworks/#{params["id"]}"
end

get "/login" do
  erb(:login)
end

get "/users/new" do
  erb(:new_user)
end

# Adding new user to DB
post "/users" do
  # need to check if a user's email already exists in the database first - prevent multiple accounts
  password_digest = BCrypt::Password.create(params["password"])
  create_user(params["name"], params["email"], password_digest)
  redirect "/login"
end

# GET /users/:id - show data connected to that user, i.e. listings, watched AW
get "/users/:id" do
  # should only be able to get this if you ARE the user in question - CHECK THIS WORKS
  
  redirect "/" unless params["id"] == current_user.id

  erb(:user)
end

post "/session" do
  result = validate_user(params["email"], params["password"])
  if result.count > 0 && BCrypt::Password.new(result.first["password_digest"]).==(params["password"])
    session[:user_id] = result.first["id"]
    redirect "/"
  else 
    erb(:login)
  end
end

delete "/session" do
  session[:user_id] = nil
  redirect "/"  
end





