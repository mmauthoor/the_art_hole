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
    watchers INTEGER
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(350),
    email VARCHAR(250),
    password_digest TEXT,
    watching INTEGER
);

CREATE TABLE watchers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    artwork_id INTEGER
);

INSERT INTO artworks (title, artist, image_url, year, media, description, user_id, watchers) VALUES ('Yoshi', 'Mark Ryden', 'https://miro.medium.com/max/1400/1*g2AcX4IwUcN4kPr2bzDsUQ.jpeg', 2007, 'Oil on canvas', 'A wonderful figure of Ryden''s imagination', 1, 0);

'Little Boy Blue', 'Mark Ryden', 'https://images.squarespace-cdn.com/content/v1/60086a96e344bd2f8788f141/1615425074839-6PZG8KIT2QPNVOJLGVZX/LittleBoyBlue.jpg', 2001, 'Oil on canvas', 'A sinister little boy enjoys riding his tricycle', 1, 0


SELECT artworks.id, artworks.title, artworks.artist, artworks.image_url FROM artworks, watchers WHERE watchers.artwork_id = artworks.id and watchers.user_id = 2;