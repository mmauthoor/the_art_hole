require "pg"

def db_query(sql, params = [])
    conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'thearthole'})
    result = conn.exec_params(sql, params)
    conn.close
    return result 
end

def create_artwork(title, artist, image_url, year, media, description, user_id)
    sql = "INSERT INTO artworks (title, artist, image_url, year, media, description, user_id) VALUES ($1, $2, $3, $4, $5, $6, $7);"
    db_query(sql, [title, artist, image_url, year, media, description, user_id])
end

def update_artwork(title, artist, image_url, year, media, description, id)
    sql = "UPDATE artworks SET title = $1, artist = $2, image_url = $3, year = $4, media = $5, description = $6 WHERE id = $7;"
    db_query(sql, [title, artist, image_url, year, media, description, id])
end

def delete_artwork(id)
    sql = "DELETE FROM artworks WHERE id = $1;"
    db_query(sql, [id])
end

def find_artwork_by_id(id)
    sql = "SELECT * FROM artworks WHERE id = $1;"
    artwork = db_query(sql, [id]).first
    return artwork
end

def find_random_artwork()
    # This query method is slow for very large tables but should be fine for a small table as in this app
    random_id = db_query("SELECT id from artworks ORDER BY random() limit 1;").first["id"]
    sql = "SELECT * FROM artworks WHERE id = $1"
    random_artwork = db_query(sql, [random_id]).first
    return random_artwork
end