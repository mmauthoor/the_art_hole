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
  artwork_user_id = OpenStruct.new(find_user_by_id(artwork.user_id))

  erb(:artwork, locals: {
    artwork: artwork, 
    artwork_user_id: artwork_user_id
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
  result = validate_user(params["email"])
  if result.none?
    # if all params not provided, provide erb again with message re please fill out full form. else 
      password_digest = BCrypt::Password.create(params["password"])
      create_user(params["name"], params["email"], password_digest)
      redirect "/login"
    # end
  else 
    erb(:new_user, locals: {
      message: "Username taken"
    })
  end
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
  redirect "/users/#{current_user.id}/edit" unless params["id"] == current_user.id
  erb(:edit_user, locals: {
    user: current_user
  })
end

put "/users/:id" do
  redirect "/login" unless logged_in?
 
  if params["password"].strip.empty? || params["new_password"].strip.empty?
    update_user_no_password(params["name"], params["email"], params["id"])
  else 
    user = find_user_by_id(params["id"])
    if BCrypt::Password.new(user["password_digest"]).==(params["password"])
      new_password_digest = BCrypt::Password.create(params["new_password"])
      update_user_with_password(params["name"], params["email"], new_password_digest, params["id"])
    end
  end
 
  redirect "/users/#{params["id"]}"
end

post "/session" do
  user = validate_user(params["email"])
  if user.any? && BCrypt::Password.new(user.first["password_digest"]).==(params["password"])
    session[:user_id] = user.first["id"]
    redirect "/"
  else 
    erb(:login, locals: {
      message: "Incorrect login"
    })
  end
end

delete "/session" do
  session[:user_id] = nil
  redirect "/"  
end

# need to add watch to db table
post "/watch" do
  
end





