
def create_watcher(user_id, artwork_id)
    # want to add a watch to the watchers table linked to the user_id and artwork_id
    sql = "INSERT INTO watchers (user_id, artwork_id) VALUES ($1, $2)"
    db_query(sql, [user_id, artwork_id])
end

def delete_watcher()
     # want to delete a watch to the watchers table linked to the user_id and artwork_id

end

