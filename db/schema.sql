CREATE DATABASE thearthole;

CREATE TABLE artworks (
    id SERIAL PRIMARY KEY,
    title TEXT,
    artist TEXT,
    image_url TEXT,
    year INTEGER,
    media TEXT,
    description TEXT,
    user_id INTEGER,
);

-- Should have made name NOT NULL and email UNIQUE when creating database
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(350),
    email VARCHAR(250),
    password_digest TEXT,
);

CREATE TABLE watchers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    artwork_id INTEGER
);

INSERT INTO artworks (title, artist, image_url, year, media, description, user_id, watchers) VALUES ('Yoshi', 'Mark Ryden', 'https://miro.medium.com/max/1400/1*g2AcX4IwUcN4kPr2bzDsUQ.jpeg', 2007, 'Oil on canvas', 'A wonderful figure of Ryden''s imagination', 1, 0);

SELECT artworks.id, artworks.title, artworks.artist, artworks.image_url FROM artworks, watchers WHERE watchers.artwork_id = artworks.id and watchers.user_id = 2;

-- SELECT artworks.id, artworks.title, artworks.artist, artworks.image_url FROM artworks JOIN watchers ON (artworks.id = watchers.artwork_id) WHERE watchers.user_id = 2;