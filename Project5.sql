-- Advance SQL Project -- Spotify Datasets
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA
select count(*) from spotify;

select count(distinct album) from spotify;

select distinct album_type from spotify;

select MAX(duration_min) from spotify;

select MIN(duration_min) from spotify;

select * from spotify
where duration_min = 0


DELETE FROM spotify
WHERE duration_min = 0

select DISTINCT channel from spotify;

select DISTINCT most_played_on from spotify;

----------------------------------------
-- Data Analysis - Easy Category
----------------------------------------
/* Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist. */

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
select * from spotify
where stream > 1000000000;

-- 2. List all albums along with their respective artists.
select album, artist
from spotify

-- 3. Get the total number of comments for tracks where licensed = TRUE.
select album,
		SUM(comments) as total_comment
from spotify
where licensed = true
group by 1

-- 4. Find all tracks that belong to the album type single.
select track, album_type
from spotify
where album_type = 'single'

-- 5. Count the total number of tracks by each artist.
select artist,
	count(*) as total
from spotify
group by 1



/* Medium Level
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.*/

-- 6.Calculate the average danceability of tracks in each album.
select album,
		avg(danceability) as avg_dance	
from spotify
group by 1


-- 7.Find the top 5 tracks with the highest energy values.
select track,
		MAX(energy)
from spotify
group by 1
order by 2 DESC
LIMIT 5


-- 8.List all tracks along with their views and likes where official_video = TRUE.
select track,
		SUM(views) as total_views,
		SUM(likes) as total_likes
from spotify
where official_video = true
group by 1


-- 9.For each album, calculate the total views of all associated tracks.
select album,
		track,
		SUM(views) as total_views
from spotify
group by 1, 2


-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube
select * from (
select track, 
		-- most_played_on,
		COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
		COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) as streamed_on_spotify
from spotify
group by 1) as t1
where 	streamed_on_spotify > streamed_on_youtube
		AND
		streamed_on_youtube <> 0




/* Advanced Level
11. Find the top 3 most-viewed tracks for each artist using window functions.
12.Write a query to find tracks where the liveness score is above the average.
13.Use a WITH clause to calculate the difference between 
the highest and lowest energy values for tracks in each album.
14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
15. Calculate the cumulative sum of likes for tracks ordered
by the number of views, using window functions */




-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
select * from (
select artist,
		track,
		views,
		row_number() over(partition by artist order by views desc) as ranks
from spotify) as t1
where ranks <= 3


-- 12.Write a query to find tracks where the liveness score is above the average.
select * from spotify
where liveness > (select avg(liveness)
from spotify)

/* 13.Use a WITH clause to calculate the difference between 
the highest and lowest energy values for tracks in each album.*/ 
with ex1 as (
select album,
		MAX(energy) as max_energy,
		MIN(energy) as min_energy
from spotify
group by album)

select album,
		max_energy - min_energy as diff
from ex1
order by 2 DESC


-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2
select *
from spotify
where energy_liveness > 1.2


/* 15. Calculate the cumulative sum of likes for tracks ordered
by the number of views, using window functions */

select track,
		SUM(likes) as total_likes
from spotify
group by track

select * from spotify


-- Query Optimization
EXPLAIN ANALYZE -- et 7.97 ms pt 0.112ms
SELECT 
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
	AND 
	most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25

CREATE INDEX artist_index ON spotify (artist);














