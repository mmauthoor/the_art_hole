-- 2-3 tables
-- Artworks
-- columns: title, artist, year, media, notes, id, user_id, watchers???

-- Users
-- columns: first name, last name, email, password, id

-- Optional??? - watchers
-- columns: id, user_id, artwork_id

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