require "bcrypt"

def create_user(name, email, password_digest)
    sql = "INSERT INTO users (name, email, password_digest) VALUES ($1, $2, $3)"
    db_query(sql, [name, email, password_digest])
end

def update_user_no_password(name, email, password_digest)
    # will need to get to re-enter old password and convert to password_digest to validate. If match, then update with new password
end

# is this function ok? not sure about passwords here. Do we even need the password here? 
def validate_user(email)
    sql = "SELECT * FROM users WHERE email = $1;"
    result = db_query(sql, [email])
    return result        
end

def find_user_by_id(id)
    db_query('SELECT * FROM users WHERE id = $1', [id]).first
end

def find_user_artworks(id)
    sql = "SELECT * FROM artworks WHERE user_id = $1;"
    result = db_query(sql, [id])
    return result
end

def update_user_no_password()
end

def update_user_with_password()
end

# could do a find user watched artworks - fidn all artworks where watcher 
