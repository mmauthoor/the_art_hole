
def create_watcher(user_id, artwork_id)
    sql = "INSERT INTO watchers (user_id, artwork_id) VALUES ($1, $2)"
    db_query(sql, [user_id, artwork_id])
end

def delete_watcher(user_id, artwork_id)
     sql = "DELETE FROM watchers WHERE user_id = $1 and artwork_id = $2;"
     db_query(sql, [user_id, artwork_id])
end

def find_watcher(user_id, artwork_id)
    sql = "SELECT * FROM watchers WHERE user_id = $1 and artwork_id = $2;"
    db_query(sql, [user_id, artwork_id])
end

def find_watched_artwork(user_id)
    sql = "SELECT artworks.id, artworks.title, artworks.artist, artworks.image_url FROM artworks, watchers WHERE watchers.artwork_id = artworks.id and watchers.user_id = $1;"
    db_query(sql, [user_id])
end

def get_watcher_count(artwork_id)
    # would be better to do "select count(*) from watchers where artwork_id = $1". Then don't have to return result.count, just return the db_query. Note it'll be stored in an array because we're using PG - need to access first item. 
    sql = "SELECT * FROM watchers WHERE artwork_id = $1;"
    result = db_query(sql, [artwork_id])
    return result.count    
end