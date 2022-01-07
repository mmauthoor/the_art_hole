require "pg"
require "pry"

def db_query(sql, params = [])
    conn = PG.connect(dbname: 'thearthole')
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


def find_random_artwork()
end