require "bcrypt"

def create_user(name, email, password_digest)
    sql = "INSERT INTO users (name, email, password_digest) VALUES ($1, $2, $3)"
    db_query(sql, [name, email, password_digest])
end

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

def update_user_no_password(name, email, id)
    sql = "UPDATE users SET name = $1, email = $2 WHERE id = $3;"
    db_query(sql, [name, email, id])
end

def update_user_with_password(name, email, new_password_digest, id)
    sql = "UPDATE users SET name = $1, email = $2, password_digest = $3 WHERE id = $4;"
    db_query(sql, [name, email, new_password_digest, id])
end

