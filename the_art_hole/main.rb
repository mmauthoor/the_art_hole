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
  redirect "/" unless logged_in?
  sql = "SELECT * FROM artworks WHERE id = $1;"
  artwork = OpenStruct.new(db_query(sql, [params['id']]).first)

  erb(:artwork, locals: {
    artwork: artwork
  })
end

delete "/artworks/:id" do
  delete_artwork(params["id"])
  
  redirect "/users/#{current_user.id}"
end

get "/artworks/:id/edit" do
  sql = "SELECT * FROM artworks WHERE id = $1;"
  artwork = OpenStruct.new(db_query(sql, [params["id"]]).first)

  redirect "/artworks/#{params["id"]}" unless current_user.id == artwork.user_id

  erb(:edit_artwork, locals: {
    artwork: artwork
  })
end 

put "/artworks/:id" do
  redirect "/login" unless logged_in?

  update_artwork(params["title"], params["artist"], params["image_url"], params["year"], params["media"], params["description"], params["id"])

  redirect "/artworks/#{params["id"]}"
end

get "/login" do
  if logged_in?
    redirect "/users/#{current_user.id}"
  end

  erb(:login)
end

get "/users/new" do
  if logged_in? 
    redirect "/"
  end
  erb(:new_user)
end

post "/users" do
  # would be better if there was some sign that a user already had an account under that email
  result = validate_user(params["email"])
  redirect "/login" unless result.count > 0
  # if result.count > 0
  #   redirect "/login" 
  # end

  password_digest = BCrypt::Password.create(params["password"])
  create_user(params["name"], params["email"], password_digest)
  redirect "/login"
end

# GET /users/:id - show data connected to that user, i.e. listings, watched AW
get "/users/:id" do
  redirect "/" unless logged_in? && params["id"] == current_user.id
  user_artworks = find_user_artworks(current_user.id)

  # then also want to list AW user is watching
  erb(:user, locals: {
    user_artworks: user_artworks
  })
end

get "/users/:id/edit" do

  erb(:edit_user, locals: {
    user: current_user
  })
  
end

put "/users/:id" do
  redirect "/login" unless logged_in?
 
  if params["password"].strip.empty? || params["new_password"].strip.empty?

    sql = "UPDATE users SET name = $1, email = $2 WHERE id = $3;"
    db_query(sql, [params["name"], params["email"], params["id"]])

    redirect "/users/#{params["id"]}"
  end

   # if user did type in a new password, password in DB should change to that IF the current password matches
  user = find_user_by_id(params["id"])
  # if BCrypt::Password.new(result.first["password_digest"]).==(params["password"])

  # need to leave password as is if not provided
  
  # redirect 
end

# check this still works after removing password params from function
post "/session" do
  result = validate_user(params["email"])
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





