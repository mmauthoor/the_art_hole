require "sinatra"
require "sinatra/reloader" if development?
require "pg"
require "bcrypt"
require "cloudinary"

require_relative "models/artwork.rb"
require_relative "models/user.rb"
require_relative "models/watcher.rb"

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
    artworks = db_query("SELECT * FROM artworks;")

    erb(:artworks, locals: {
      artworks: artworks, 
      header: "Main Gallery"
    })
  else

    featured_artwork = OpenStruct.new(find_random_artwork())

    erb(:index, :layout => false, 
    locals: {
      featured_artwork: featured_artwork
    })
  end 
end

get "/artworks/new" do
  redirect "/" unless logged_in?
  erb(:new_artwork)  
end

post "/artworks" do
  redirect "/login" unless logged_in?
  
  image_file = params["image_file"]["tempfile"]
  options = {
    cloud_name: 'dww0xtsd0', 
    api_key: ENV['CLOUDINARY_API_KEY'],
    api_secret: ENV['CLOUDINARY_API_SECRET']
  }

  image_url = Cloudinary::Uploader.upload(image_file, options)["url"]

  create_artwork(params["title"], params["artist"], image_url, params["year"], params["media"], params["description"], current_user.id)

  redirect "/users/#{current_user.id}"
end

get "/artworks/:id" do
  redirect "/" unless logged_in?

  result = find_artwork_by_id(params["id"])
  if result.nil?
    redirect "/"
  end
  
  # would probably be easier to get these details through sql by joining tables
  artwork = OpenStruct.new(result)
  artwork_seller = OpenStruct.new(find_user_by_id(artwork.user_id))
  watch_status = find_watcher(current_user.id, params['id'])
  watcher_number = get_watcher_count(artwork.id)

  erb(:artwork, locals: {
    artwork: artwork, 
    artwork_seller: artwork_seller,
    is_watching: watch_status,
    watcher_number: watcher_number
  })
end

delete "/artworks/:id" do
  redirect "/" unless logged_in?

  delete_artwork(params["id"])
  
  redirect "/users/#{current_user.id}"
end

get "/artworks/:id/edit" do
  redirect "/" unless logged_in?

  artwork = OpenStruct.new(find_artwork_by_id(params["id"]))

  redirect "/artworks/#{params["id"]}" unless current_user.id == artwork.user_id

  erb(:edit_artwork, locals: {
    artwork: artwork
  })
end 

put "/artworks/:id" do
  redirect "/login" unless logged_in?

  if params["image_file"].nil?
    artwork = find_artwork_by_id(params["id"])

    update_artwork(params["title"], params["artist"], artwork["image_url"], params["year"], params["media"], params["description"], params["id"])
  else
    image_file = params["image_file"]["tempfile"]
    options = {
      cloud_name: 'dww0xtsd0', 
      api_key: ENV['CLOUDINARY_API_KEY'],
      api_secret: ENV['CLOUDINARY_API_SECRET']
    }

    image_url = Cloudinary::Uploader.upload(image_file, options)["url"]

    update_artwork(params["title"], params["artist"], image_url, params["year"], params["media"], params["description"], params["id"])
  end
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
  user = validate_user(params["email"])
  if user.none?
      password_digest = BCrypt::Password.create(params["password"])
      create_user(params["name"], params["email"], password_digest)
      redirect "/login"
  else 
    erb(:new_user, locals: {
      message: "User already exists"
    })
  end
end

get "/users/:id" do
  redirect "/" unless logged_in?
  redirect "/users/#{current_user.id}" unless params["id"] == current_user.id

  user_artworks = find_user_artworks(current_user.id)
  watched_artworks = find_watched_artwork(current_user.id)

  erb(:user, locals: {
    user_artworks: user_artworks,
    watched_artworks: watched_artworks
  })
end

get "/users/:id/edit" do
  redirect "/" unless logged_in?
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

post "/watchers" do
  redirect "/" unless logged_in?

  create_watcher(current_user.id, params["artwork_id"])
  redirect "/artworks/#{params["artwork_id"]}"
end

delete "/watchers" do
  redirect "/" unless logged_in?

  delete_watcher(current_user.id, params["artwork_id"])
  redirect "/artworks/#{params["artwork_id"]}"
end




