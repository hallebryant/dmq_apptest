Timing is on.
----------------------------------------------------------------------
>>> PREPARING ENVIRONMENT: DROPPING INDEXES...
----------------------------------------------------------------------
DROP INDEX
Time: 11.394 ms
DROP INDEX
Time: 1.931 ms
DROP INDEX
Time: 1.289 ms
DROP INDEX
Time: 1.368 ms
DROP INDEX
Time: 1.311 ms
DROP INDEX
Time: 1.759 ms
DROP INDEX
Time: 0.815 ms
DROP INDEX
Time: 2.081 ms
DROP INDEX
Time: 1.117 ms
DROP INDEX
Time: 0.524 ms
DISCARD ALL
Time: 0.097 ms
 
>>> PHASE 1: BENCHMARKING RAW TABLES (NO INDEXES)
-- Q1: Genre Fingerprinting (Raw) --
                                                                                             QUERY PLAN                                                                                             
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=6205.21..6205.35 rows=54 width=82) (actual time=58.690..61.760 rows=36 loops=1)
   Sort Key: (round((avg(a.energy))::numeric, 3)) DESC
   Sort Method: quicksort  Memory: 27kB
   Buffers: shared hit=39307
   ->  Finalize GroupAggregate  (cost=6158.43..6203.66 rows=54 width=82) (actual time=58.218..61.493 rows=36 loops=1)
         Group Key: g.genre_name
         Filter: (count(t.track_id) > 100)
         Rows Removed by Filter: 83
         Buffers: shared hit=39304
         ->  Gather Merge  (cost=6158.43..6196.24 rows=324 width=82) (actual time=58.169..61.348 rows=301 loops=1)
               Workers Planned: 2
               Workers Launched: 2
               Buffers: shared hit=39304
               ->  Sort  (cost=5158.41..5158.81 rows=162 width=82) (actual time=54.017..54.028 rows=100 loops=3)
                     Sort Key: g.genre_name
                     Sort Method: quicksort  Memory: 46kB
                     Buffers: shared hit=39304
                     Worker 0:  Sort Method: quicksort  Memory: 46kB
                     Worker 1:  Sort Method: quicksort  Memory: 47kB
                     ->  Partial HashAggregate  (cost=5150.84..5152.46 rows=162 width=82) (actual time=53.713..53.740 rows=100 loops=3)
                           Group Key: g.genre_name
                           Batches: 1  Memory Usage: 64kB
                           Buffers: shared hit=39288
                           Worker 0:  Batches: 1  Memory Usage: 64kB
                           Worker 1:  Batches: 1  Memory Usage: 64kB
                           ->  Hash Join  (cost=5.64..5022.70 rows=12814 width=22) (actual time=1.563..51.294 rows=7383 loops=3)
                                 Hash Cond: (tg.genre_id = g.genre_id)
                                 Buffers: shared hit=39288
                                 ->  Nested Loop  (cost=1.00..4983.54 rows=12814 width=16) (actual time=1.268..49.249 rows=7383 loops=3)
                                       Buffers: shared hit=39254
                                       ->  Merge Join  (cost=0.58..2148.49 rows=5361 width=16) (actual time=0.982..25.613 rows=4289 loops=3)
                                             Merge Cond: (t.track_id = a.track_id)
                                             Buffers: shared hit=651
                                             ->  Parallel Index Only Scan using "Tracks_pkey" on "Tracks" t  (cost=0.29..1928.23 rows=39815 width=4) (actual time=0.221..14.782 rows=25269 loops=3)
                                                   Heap Fetches: 0
                                                   Buffers: shared hit=214
                                             ->  Index Scan using "Audio_pkey" on "Audio" a  (cost=0.29..456.28 rows=12866 width=12) (actual time=0.019..7.480 rows=12866 loops=3)
                                                   Buffers: shared hit=437
                                       ->  Index Only Scan using "TrackGenres_pkey" on "TrackGenres" tg  (cost=0.42..0.50 rows=3 width=8) (actual time=0.005..0.005 rows=2 loops=12866)
                                             Index Cond: (track_id = t.track_id)
                                             Heap Fetches: 0
                                             Buffers: shared hit=38603
                                 ->  Hash  (cost=2.62..2.62 rows=162 width=14) (actual time=0.129..0.130 rows=162 loops=3)
                                       Buckets: 1024  Batches: 1  Memory Usage: 16kB
                                       Buffers: shared hit=3
                                       ->  Seq Scan on "Genres" g  (cost=0.00..2.62 rows=162 width=14) (actual time=0.015..0.041 rows=162 loops=3)
                                             Buffers: shared hit=3
 Planning:
   Buffers: shared hit=288 dirtied=1
 Planning Time: 5.511 ms
 Execution Time: 62.047 ms
(51 rows)

Time: 74.376 ms
-- Q2: Top Artists Yearly (Raw) --
                                                                            QUERY PLAN                                                                            
------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=4919.60..4924.12 rows=1807 width=39) (actual time=72.623..72.628 rows=54 loops=1)
   Sort Key: rankedstats.release_year DESC, rankedstats.yr_rank
   Sort Method: quicksort  Memory: 29kB
   Buffers: shared hit=2523
   ->  Subquery Scan on rankedstats  (cost=4645.70..4821.85 rows=1807 width=39) (actual time=72.245..72.605 rows=54 loops=1)
         Filter: (rankedstats.yr_rank <= 3)
         Rows Removed by Filter: 992
         Buffers: shared hit=2517
         ->  WindowAgg  (cost=4645.70..4754.10 rows=5420 width=39) (actual time=72.245..72.544 rows=1046 loops=1)
               Buffers: shared hit=2517
               ->  Sort  (cost=4645.70..4659.25 rows=5420 width=31) (actual time=72.234..72.272 rows=1046 loops=1)
                     Sort Key: yearlystats.release_year, yearlystats.total_listens DESC
                     Sort Method: quicksort  Memory: 132kB
                     Buffers: shared hit=2517
                     ->  Subquery Scan on yearlystats  (cost=4174.05..4309.55 rows=5420 width=31) (actual time=71.647..71.949 rows=1046 loops=1)
                           Buffers: shared hit=2517
                           ->  HashAggregate  (cost=4174.05..4255.35 rows=5420 width=31) (actual time=71.647..71.877 rows=1046 loops=1)
                                 Group Key: art.artist_name, date_part('year'::text, (t.track_date_recorded)::timestamp without time zone)
                                 Batches: 1  Memory Usage: 337kB
                                 Buffers: shared hit=2517
                                 ->  Hash Join  (cost=562.61..4133.40 rows=5420 width=27) (actual time=5.481..70.221 rows=5370 loops=1)
                                       Hash Cond: (t.artist_id = art.artist_id)
                                       Buffers: shared hit=2517
                                       ->  Seq Scan on "Tracks" t  (cost=0.00..3529.46 rows=5420 width=12) (actual time=0.006..63.181 rows=5370 loops=1)
                                             Filter: (track_date_recorded > '2000-01-01'::date)
                                             Rows Removed by Filter: 90187
                                             Buffers: shared hit=2335
                                       ->  Hash  (cost=351.16..351.16 rows=16916 width=19) (actual time=5.248..5.249 rows=16916 loops=1)
                                             Buckets: 32768  Batches: 1  Memory Usage: 1127kB
                                             Buffers: shared hit=182
                                             ->  Seq Scan on "Artists" art  (cost=0.00..351.16 rows=16916 width=19) (actual time=0.007..3.020 rows=16916 loops=1)
                                                   Buffers: shared hit=182
 Planning:
   Buffers: shared hit=109
 Planning Time: 2.406 ms
 Execution Time: 74.213 ms
(36 rows)

Time: 77.698 ms
-- Q3: Undiscovered Gems (Raw) --
                                                          QUERY PLAN                                                          
------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=3780.96..3780.97 rows=1 width=41) (actual time=3.069..3.071 rows=0 loops=1)
   Buffers: shared hit=85
   InitPlan 1 (returns $0)
     ->  Aggregate  (cost=3529.47..3529.48 rows=1 width=32) (never executed)
           ->  Seq Scan on "Tracks"  (cost=0.00..3290.57 rows=95557 width=4) (never executed)
   ->  Sort  (cost=251.49..251.49 rows=1 width=41) (actual time=3.067..3.069 rows=0 loops=1)
         Sort Key: s.song_hotttnesss DESC
         Sort Method: quicksort  Memory: 25kB
         Buffers: shared hit=85
         ->  Nested Loop  (cost=0.58..251.48 rows=1 width=41) (actual time=3.061..3.063 rows=0 loops=1)
               Buffers: shared hit=82
               ->  Nested Loop  (cost=0.29..251.14 rows=1 width=30) (actual time=3.061..3.061 rows=0 loops=1)
                     Buffers: shared hit=82
                     ->  Seq Scan on "Social" s  (cost=0.00..242.83 rows=1 width=8) (actual time=3.060..3.060 rows=0 loops=1)
                           Filter: (song_hotttnesss > '0.6'::double precision)
                           Rows Removed by Filter: 12866
                           Buffers: shared hit=82
                     ->  Index Scan using "Tracks_pkey" on "Tracks" t  (cost=0.29..8.32 rows=1 width=30) (never executed)
                           Index Cond: (track_id = s.track_id)
                           Filter: ((track_listens)::numeric < $0)
               ->  Index Scan using "Artists_pkey" on "Artists" art  (cost=0.29..0.34 rows=1 width=19) (never executed)
                     Index Cond: (artist_id = t.artist_id)
 Planning:
   Buffers: shared hit=73
 Planning Time: 0.721 ms
 Execution Time: 3.096 ms
(26 rows)

Time: 5.048 ms
-- Q4: Artist Profiling (Raw) --
                                                                                          QUERY PLAN                                                                                           
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=17055.62..52951.40 rows=10 width=309) (actual time=638.911..710.317 rows=10 loops=1)
   Buffers: shared hit=66260, temp read=7214 written=1783
   ->  Result  (cost=17055.62..60738368.00 rows=16916 width=309) (actual time=638.910..710.315 rows=10 loops=1)
         Buffers: shared hit=66260, temp read=7214 written=1783
         ->  Sort  (cost=17055.62..17097.91 rows=16916 width=91) (actual time=629.314..629.321 rows=10 loops=1)
               Sort Key: (COALESCE(sum(t.track_listens), '0'::bigint)) DESC, a.artist_favorites DESC
               Sort Method: top-N heapsort  Memory: 27kB
               Buffers: shared hit=2689, temp read=7214 written=1783
               ->  GroupAggregate  (cost=13456.87..16690.07 rows=16916 width=91) (actual time=58.703..626.465 rows=16916 loops=1)
                     Group Key: a.artist_id
                     Buffers: shared hit=2689, temp read=7214 written=1783
                     ->  Merge Left Join  (cost=13456.87..15045.26 rows=95557 width=58) (actual time=58.674..247.973 rows=968142 loops=1)
                           Merge Cond: (a.artist_id = t.artist_id)
                           Buffers: shared hit=2689, temp read=6139 written=703
                           ->  Merge Left Join  (cost=2261.75..2374.58 rows=16916 width=46) (actual time=14.588..23.868 rows=27047 loops=1)
                                 Merge Cond: (a.artist_id = arl.artist_id)
                                 Buffers: shared hit=354
                                 ->  Sort  (cost=2086.23..2128.52 rows=16916 width=31) (actual time=13.805..16.511 rows=23252 loops=1)
                                       Sort Key: a.artist_id
                                       Sort Method: quicksort  Memory: 2563kB
                                       Buffers: shared hit=336
                                       ->  Hash Right Join  (cost=562.61..898.21 rows=16916 width=31) (actual time=2.981..8.669 rows=23252 loops=1)
                                             Hash Cond: (al.artist_id = a.artist_id)
                                             Buffers: shared hit=336
                                             ->  Seq Scan on "Albums" al  (cost=0.00..297.83 rows=14383 width=8) (actual time=0.006..1.983 rows=14383 loops=1)
                                                   Buffers: shared hit=154
                                             ->  Hash  (cost=351.16..351.16 rows=16916 width=27) (actual time=2.956..2.956 rows=16916 loops=1)
                                                   Buckets: 32768  Batches: 1  Memory Usage: 1199kB
                                                   Buffers: shared hit=182
                                                   ->  Seq Scan on "Artists" a  (cost=0.00..351.16 rows=16916 width=27) (actual time=0.002..1.267 rows=16916 loops=1)
                                                         Buffers: shared hit=182
                                 ->  Sort  (cost=175.53..180.24 rows=1883 width=19) (actual time=0.780..1.243 rows=6154 loops=1)
                                       Sort Key: arl.artist_id
                                       Sort Method: quicksort  Memory: 170kB
                                       Buffers: shared hit=18
                                       ->  Hash Left Join  (cost=40.32..73.10 rows=1883 width=19) (actual time=0.248..0.591 rows=1883 loops=1)
                                             Hash Cond: (arl.label_id = l.label_id)
                                             Buffers: shared hit=18
                                             ->  Seq Scan on "ArtistLabels" arl  (cost=0.00..27.83 rows=1883 width=8) (actual time=0.005..0.140 rows=1883 loops=1)
                                                   Buffers: shared hit=9
                                             ->  Hash  (cost=22.92..22.92 rows=1392 width=19) (actual time=0.239..0.239 rows=1392 loops=1)
                                                   Buckets: 2048  Batches: 1  Memory Usage: 89kB
                                                   Buffers: shared hit=9
                                                   ->  Seq Scan on "Labels" l  (cost=0.00..22.92 rows=1392 width=19) (actual time=0.002..0.144 rows=1392 loops=1)
                                                         Buffers: shared hit=9
                           ->  Sort  (cost=11195.08..11433.97 rows=95557 width=16) (actual time=44.082..106.652 rows=962648 loops=1)
                                 Sort Key: t.artist_id
                                 Sort Method: external sort  Disk: 2808kB
                                 Buffers: shared hit=2335, temp read=3492 written=703
                                 ->  Seq Scan on "Tracks" t  (cost=0.00..3290.57 rows=95557 width=16) (actual time=0.003..9.695 rows=95557 loops=1)
                                       Buffers: shared hit=2335
         SubPlan 1
           ->  Limit  (cost=3589.56..3589.57 rows=1 width=18) (actual time=8.097..8.097 rows=1 loops=10)
                 Buffers: shared hit=63571
                 ->  Sort  (cost=3589.56..3589.64 rows=29 width=18) (actual time=8.096..8.096 rows=1 loops=10)
                       Sort Key: (count(*)) DESC
                       Sort Method: top-N heapsort  Memory: 25kB
                       Buffers: shared hit=63571
                       ->  GroupAggregate  (cost=3588.91..3589.42 rows=29 width=18) (actual time=7.981..8.092 rows=21 loops=10)
                             Group Key: g.genre_name
                             Buffers: shared hit=63571
                             ->  Sort  (cost=3588.91..3588.98 rows=29 width=10) (actual time=7.969..8.011 rows=1452 loops=10)
                                   Sort Key: g.genre_name
                                   Sort Method: quicksort  Memory: 42kB
                                   Buffers: shared hit=63571
                                   ->  Nested Loop  (cost=0.56..3588.21 rows=29 width=10) (actual time=1.956..7.779 rows=1452 loops=10)
                                         Buffers: shared hit=63571
                                         ->  Nested Loop  (cost=0.42..3583.49 rows=29 width=4) (actual time=1.954..7.126 rows=1452 loops=10)
                                               Buffers: shared hit=34535
                                               ->  Seq Scan on "Tracks" t2  (cost=0.00..3529.46 rows=12 width=4) (actual time=1.945..6.247 rows=373 loops=10)
                                                     Filter: (artist_id = a.artist_id)
                                                     Rows Removed by Filter: 95184
                                                     Buffers: shared hit=23350
                                               ->  Index Only Scan using "TrackGenres_pkey" on "TrackGenres" tg  (cost=0.42..4.47 rows=3 width=8) (actual time=0.002..0.002 rows=4 loops=3728)
                                                     Index Cond: (track_id = t2.track_id)
                                                     Heap Fetches: 0
                                                     Buffers: shared hit=11185
                                         ->  Index Scan using "Genres_pkey" on "Genres" g  (cost=0.14..0.16 rows=1 width=14) (actual time=0.000..0.000 rows=1 loops=14518)
                                               Index Cond: (genre_id = tg.genre_id)
                                               Buffers: shared hit=29036
 Planning:
   Buffers: shared hit=168
 Planning Time: 0.800 ms
 Execution Time: 710.696 ms
(84 rows)

Time: 712.748 ms
 
>>> PHASE 2: APPLYING INDEXES...
CREATE INDEX
Time: 79.544 ms
CREATE INDEX
Time: 54.283 ms
CREATE INDEX
Time: 4.345 ms
CREATE INDEX
Time: 27.287 ms
CREATE INDEX
Time: 26.674 ms
CREATE INDEX
Time: 5.839 ms
CREATE INDEX
Time: 4.350 ms
CREATE INDEX
Time: 2.377 ms
CREATE INDEX
Time: 1.698 ms
CREATE INDEX
Time: 5.216 ms
ANALYZE
Time: 666.668 ms
DISCARD ALL
Time: 0.061 ms
 
>>> PHASE 3: BENCHMARKING OPTIMIZED TABLES (WITH INDEXES)
-- Q1: Genre Fingerprinting (Optimized) --
                                                                                            QUERY PLAN                                                                                             
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=6206.59..6206.72 rows=54 width=82) (actual time=14.153..14.990 rows=36 loops=1)
   Sort Key: (round((avg(a.energy))::numeric, 3)) DESC
   Sort Method: quicksort  Memory: 27kB
   Buffers: shared hit=39267 read=34
   ->  Finalize GroupAggregate  (cost=6159.81..6205.04 rows=54 width=82) (actual time=14.003..14.977 rows=36 loops=1)
         Group Key: g.genre_name
         Filter: (count(t.track_id) > 100)
         Rows Removed by Filter: 83
         Buffers: shared hit=39267 read=34
         ->  Gather Merge  (cost=6159.81..6197.61 rows=324 width=82) (actual time=13.990..14.894 rows=294 loops=1)
               Workers Planned: 2
               Workers Launched: 2
               Buffers: shared hit=39267 read=34
               ->  Sort  (cost=5159.78..5160.19 rows=162 width=82) (actual time=12.405..12.411 rows=98 loops=3)
                     Sort Key: g.genre_name
                     Sort Method: quicksort  Memory: 45kB
                     Buffers: shared hit=39267 read=34
                     Worker 0:  Sort Method: quicksort  Memory: 46kB
                     Worker 1:  Sort Method: quicksort  Memory: 47kB
                     ->  Partial HashAggregate  (cost=5152.22..5153.84 rows=162 width=82) (actual time=12.336..12.349 rows=98 loops=3)
                           Group Key: g.genre_name
                           Batches: 1  Memory Usage: 64kB
                           Buffers: shared hit=39251 read=34
                           Worker 0:  Batches: 1  Memory Usage: 64kB
                           Worker 1:  Batches: 1  Memory Usage: 64kB
                           ->  Hash Join  (cost=5.87..5024.08 rows=12814 width=22) (actual time=0.333..11.326 rows=7383 loops=3)
                                 Hash Cond: (tg.genre_id = g.genre_id)
                                 Buffers: shared hit=39251 read=34
                                 ->  Nested Loop  (cost=1.23..4984.92 rows=12814 width=16) (actual time=0.289..10.485 rows=7383 loops=3)
                                       Buffers: shared hit=39220 read=34
                                       ->  Merge Join  (cost=0.81..2149.86 rows=5361 width=16) (actual time=0.268..6.370 rows=4289 loops=3)
                                             Merge Cond: (t.track_id = a.track_id)
                                             Buffers: shared hit=617 read=34
                                             ->  Parallel Index Only Scan using "Tracks_pkey" on "Tracks" t  (cost=0.29..1928.23 rows=39815 width=4) (actual time=0.015..1.675 rows=25269 loops=3)
                                                   Heap Fetches: 0
                                                   Buffers: shared hit=214
                                             ->  Index Scan using idx_audio_track_id on "Audio" a  (cost=0.29..456.28 rows=12866 width=12) (actual time=0.123..2.919 rows=12866 loops=3)
                                                   Buffers: shared hit=403 read=34
                                       ->  Index Only Scan using "TrackGenres_pkey" on "TrackGenres" tg  (cost=0.42..0.50 rows=3 width=8) (actual time=0.001..0.001 rows=2 loops=12866)
                                             Index Cond: (track_id = t.track_id)
                                             Heap Fetches: 0
                                             Buffers: shared hit=38603
                                 ->  Hash  (cost=2.62..2.62 rows=162 width=14) (actual time=0.028..0.028 rows=162 loops=3)
                                       Buckets: 1024  Batches: 1  Memory Usage: 16kB
                                       Buffers: shared hit=3
                                       ->  Seq Scan on "Genres" g  (cost=0.00..2.62 rows=162 width=14) (actual time=0.004..0.012 rows=162 loops=3)
                                             Buffers: shared hit=3
 Planning:
   Buffers: shared hit=89 read=16
 Planning Time: 0.839 ms
 Execution Time: 15.031 ms
(51 rows)

Time: 16.092 ms
-- Q2: Top Artists Yearly (Optimized) --
                                                                                    QUERY PLAN                                                                                    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=3813.39..3817.72 rows=1730 width=39) (actual time=5.696..5.698 rows=54 loops=1)
   Sort Key: rankedstats.release_year DESC, rankedstats.yr_rank
   Sort Method: quicksort  Memory: 29kB
   Buffers: shared hit=690 read=9
   ->  Subquery Scan on rankedstats  (cost=3551.64..3720.35 rows=1730 width=39) (actual time=5.365..5.686 rows=54 loops=1)
         Filter: (rankedstats.yr_rank <= 3)
         Rows Removed by Filter: 992
         Buffers: shared hit=690 read=9
         ->  WindowAgg  (cost=3551.64..3655.46 rows=5191 width=39) (actual time=5.365..5.640 rows=1046 loops=1)
               Buffers: shared hit=690 read=9
               ->  Sort  (cost=3551.64..3564.62 rows=5191 width=31) (actual time=5.361..5.394 rows=1046 loops=1)
                     Sort Key: yearlystats.release_year, yearlystats.total_listens DESC
                     Sort Method: quicksort  Memory: 132kB
                     Buffers: shared hit=690 read=9
                     ->  Subquery Scan on yearlystats  (cost=3101.53..3231.31 rows=5191 width=31) (actual time=4.994..5.154 rows=1046 loops=1)
                           Buffers: shared hit=690 read=9
                           ->  HashAggregate  (cost=3101.53..3179.40 rows=5191 width=31) (actual time=4.994..5.089 rows=1046 loops=1)
                                 Group Key: art.artist_name, date_part('year'::text, (t.track_date_recorded)::timestamp without time zone)
                                 Batches: 1  Memory Usage: 337kB
                                 Buffers: shared hit=690 read=9
                                 ->  Hash Join  (cost=623.13..3062.60 rows=5191 width=27) (actual time=2.750..4.320 rows=5370 loops=1)
                                       Hash Cond: (t.artist_id = art.artist_id)
                                       Buffers: shared hit=690 read=9
                                       ->  Bitmap Heap Scan on "Tracks" t  (cost=60.52..2460.41 rows=5191 width=12) (actual time=0.585..1.164 rows=5370 loops=1)
                                             Recheck Cond: (track_date_recorded > '2000-01-01'::date)
                                             Heap Blocks: exact=508
                                             Buffers: shared hit=508 read=9
                                             ->  Bitmap Index Scan on idx_tracks_date_recorded  (cost=0.00..59.22 rows=5191 width=0) (actual time=0.554..0.555 rows=5370 loops=1)
                                                   Index Cond: (track_date_recorded > '2000-01-01'::date)
                                                   Buffers: shared read=9
                                       ->  Hash  (cost=351.16..351.16 rows=16916 width=19) (actual time=2.158..2.158 rows=16916 loops=1)
                                             Buckets: 32768  Batches: 1  Memory Usage: 1127kB
                                             Buffers: shared hit=182
                                             ->  Seq Scan on "Artists" art  (cost=0.00..351.16 rows=16916 width=19) (actual time=0.002..0.958 rows=16916 loops=1)
                                                   Buffers: shared hit=182
 Planning:
   Buffers: shared hit=26 read=3
 Planning Time: 0.234 ms
 Execution Time: 5.719 ms
(39 rows)

Time: 6.110 ms
-- Q3: Undiscovered Gems (Optimized) --
                                                                         QUERY PLAN                                                                          
-------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=3530.34..3545.28 rows=1 width=41) (actual time=0.002..0.002 rows=0 loops=1)
   Buffers: shared hit=2
   InitPlan 1 (returns $0)
     ->  Aggregate  (cost=3529.47..3529.48 rows=1 width=32) (never executed)
           ->  Seq Scan on "Tracks"  (cost=0.00..3290.57 rows=95557 width=4) (never executed)
   ->  Nested Loop  (cost=0.86..15.81 rows=1 width=41) (actual time=0.001..0.002 rows=0 loops=1)
         Buffers: shared hit=2
         ->  Nested Loop  (cost=0.58..15.47 rows=1 width=30) (actual time=0.001..0.002 rows=0 loops=1)
               Buffers: shared hit=2
               ->  Index Scan Backward using idx_social_hotttnesss on "Social" s  (cost=0.29..7.15 rows=1 width=8) (actual time=0.001..0.001 rows=0 loops=1)
                     Index Cond: (song_hotttnesss > '0.6'::double precision)
                     Buffers: shared hit=2
               ->  Index Scan using "Tracks_pkey" on "Tracks" t  (cost=0.29..8.32 rows=1 width=30) (never executed)
                     Index Cond: (track_id = s.track_id)
                     Filter: ((track_listens)::numeric < $0)
         ->  Index Scan using "Artists_pkey" on "Artists" art  (cost=0.29..0.34 rows=1 width=19) (never executed)
               Index Cond: (artist_id = t.artist_id)
 Planning:
   Buffers: shared hit=34 read=7
 Planning Time: 0.260 ms
 Execution Time: 0.014 ms
(21 rows)

Time: 0.437 ms
-- Q4: Artist Profiling (Optimized) --
                                                                                          QUERY PLAN                                                                                           
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=12707.53..13574.08 rows=10 width=309) (actual time=535.830..548.676 rows=10 loops=1)
   Buffers: shared hit=209391 read=107, temp read=1075 written=1080
   ->  Result  (cost=12707.53..1478559.50 rows=16916 width=309) (actual time=535.829..548.673 rows=10 loops=1)
         Buffers: shared hit=209391 read=107, temp read=1075 written=1080
         ->  Sort  (cost=12707.53..12749.82 rows=16916 width=91) (actual time=534.242..534.246 rows=10 loops=1)
               Sort Key: (COALESCE(sum(t.track_listens), '0'::bigint)) DESC, a.artist_favorites DESC
               Sort Method: top-N heapsort  Memory: 27kB
               Buffers: shared hit=168644 read=107, temp read=1075 written=1080
               ->  GroupAggregate  (cost=2262.05..12341.99 rows=16916 width=91) (actual time=10.336..532.203 rows=16916 loops=1)
                     Group Key: a.artist_id
                     Buffers: shared hit=168644 read=107, temp read=1075 written=1080
                     ->  Merge Left Join  (cost=2262.05..10697.18 rows=95557 width=58) (actual time=10.308..214.389 rows=968142 loops=1)
                           Merge Cond: (a.artist_id = t.artist_id)
                           Buffers: shared hit=168644 read=107
                           ->  Merge Left Join  (cost=2261.75..2374.58 rows=16916 width=46) (actual time=10.300..15.172 rows=27047 loops=1)
                                 Merge Cond: (a.artist_id = arl.artist_id)
                                 Buffers: shared hit=354
                                 ->  Sort  (cost=2086.23..2128.52 rows=16916 width=31) (actual time=9.603..10.991 rows=23252 loops=1)
                                       Sort Key: a.artist_id
                                       Sort Method: quicksort  Memory: 2563kB
                                       Buffers: shared hit=336
                                       ->  Hash Right Join  (cost=562.61..898.21 rows=16916 width=31) (actual time=2.596..6.201 rows=23252 loops=1)
                                             Hash Cond: (al.artist_id = a.artist_id)
                                             Buffers: shared hit=336
                                             ->  Seq Scan on "Albums" al  (cost=0.00..297.83 rows=14383 width=8) (actual time=0.002..0.655 rows=14383 loops=1)
                                                   Buffers: shared hit=154
                                             ->  Hash  (cost=351.16..351.16 rows=16916 width=27) (actual time=2.590..2.591 rows=16916 loops=1)
                                                   Buckets: 32768  Batches: 1  Memory Usage: 1199kB
                                                   Buffers: shared hit=182
                                                   ->  Seq Scan on "Artists" a  (cost=0.00..351.16 rows=16916 width=27) (actual time=0.003..1.190 rows=16916 loops=1)
                                                         Buffers: shared hit=182
                                 ->  Sort  (cost=175.53..180.24 rows=1883 width=19) (actual time=0.694..0.944 rows=6154 loops=1)
                                       Sort Key: arl.artist_id
                                       Sort Method: quicksort  Memory: 170kB
                                       Buffers: shared hit=18
                                       ->  Hash Left Join  (cost=40.32..73.10 rows=1883 width=19) (actual time=0.190..0.488 rows=1883 loops=1)
                                             Hash Cond: (arl.label_id = l.label_id)
                                             Buffers: shared hit=18
                                             ->  Seq Scan on "ArtistLabels" arl  (cost=0.00..27.83 rows=1883 width=8) (actual time=0.006..0.090 rows=1883 loops=1)
                                                   Buffers: shared hit=9
                                             ->  Hash  (cost=22.92..22.92 rows=1392 width=19) (actual time=0.181..0.181 rows=1392 loops=1)
                                                   Buckets: 2048  Batches: 1  Memory Usage: 89kB
                                                   Buffers: shared hit=9
                                                   ->  Seq Scan on "Labels" l  (cost=0.00..22.92 rows=1392 width=19) (actual time=0.004..0.081 rows=1392 loops=1)
                                                         Buffers: shared hit=9
                           ->  Index Scan using idx_tracks_artist_id on "Tracks" t  (cost=0.29..7085.85 rows=95557 width=16) (actual time=0.007..82.519 rows=962648 loops=1)
                                 Buffers: shared hit=168290 read=107
         SubPlan 1
           ->  Limit  (cost=86.64..86.64 rows=1 width=18) (actual time=1.440..1.440 rows=1 loops=10)
                 Buffers: shared hit=40747
                 ->  Sort  (cost=86.64..86.71 rows=29 width=18) (actual time=1.440..1.440 rows=1 loops=10)
                       Sort Key: (count(*)) DESC
                       Sort Method: top-N heapsort  Memory: 25kB
                       Buffers: shared hit=40747
                       ->  GroupAggregate  (cost=85.99..86.49 rows=29 width=18) (actual time=1.323..1.437 rows=21 loops=10)
                             Group Key: g.genre_name
                             Buffers: shared hit=40747
                             ->  Sort  (cost=85.99..86.06 rows=29 width=10) (actual time=1.313..1.356 rows=1452 loops=10)
                                   Sort Key: g.genre_name
                                   Sort Method: quicksort  Memory: 42kB
                                   Buffers: shared hit=40747
                                   ->  Nested Loop  (cost=0.86..85.28 rows=29 width=10) (actual time=0.007..1.132 rows=1452 loops=10)
                                         Buffers: shared hit=40747
                                         ->  Nested Loop  (cost=0.71..80.57 rows=29 width=4) (actual time=0.006..0.481 rows=1452 loops=10)
                                               Buffers: shared hit=11711
                                               ->  Index Scan using idx_tracks_artist_id on "Tracks" t2  (cost=0.29..26.54 rows=12 width=4) (actual time=0.004..0.053 rows=373 loops=10)
                                                     Index Cond: (artist_id = a.artist_id)
                                                     Buffers: shared hit=526
                                               ->  Index Only Scan using "TrackGenres_pkey" on "TrackGenres" tg  (cost=0.42..4.47 rows=3 width=8) (actual time=0.001..0.001 rows=4 loops=3728)
                                                     Index Cond: (track_id = t2.track_id)
                                                     Heap Fetches: 0
                                                     Buffers: shared hit=11185
                                         ->  Index Scan using "Genres_pkey" on "Genres" g  (cost=0.14..0.16 rows=1 width=14) (actual time=0.000..0.000 rows=1 loops=14518)
                                               Index Cond: (genre_id = tg.genre_id)
                                               Buffers: shared hit=29036
 Planning:
   Buffers: shared hit=102 read=12
 Planning Time: 1.716 ms
 Execution Time: 548.719 ms
(79 rows)

Time: 550.752 ms
 
>>> PHASE 4: BENCHMARKING DBT MATERIALIZED TABLES
>>> (Reading from pre-calculated tables in "analytics" schema)
-- Q1: Genre Fingerprinting (From DBT Mart) --
                                                       QUERY PLAN                                                       
------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=6.76..7.08 rows=128 width=34) (actual time=0.036..0.040 rows=128 loops=1)
   Sort Key: avg_energy DESC
   Sort Method: quicksort  Memory: 34kB
   Buffers: shared hit=1
   ->  Seq Scan on mart_genre_profiles  (cost=0.00..2.28 rows=128 width=34) (actual time=0.005..0.010 rows=128 loops=1)
         Buffers: shared hit=1
 Planning:
   Buffers: shared hit=14
 Planning Time: 0.048 ms
 Execution Time: 0.050 ms
(10 rows)

Time: 0.202 ms
-- Q2: Top Artists Yearly (From DBT Mart) --
                                                         QUERY PLAN                                                          
-----------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=34.98..35.40 rows=167 width=39) (actual time=0.103..0.109 rows=167 loops=1)
   Sort Key: release_year DESC, rank_in_year
   Sort Method: quicksort  Memory: 38kB
   Buffers: shared hit=12
   ->  Seq Scan on mart_top_artists_yearly  (cost=0.00..28.81 rows=167 width=39) (actual time=0.003..0.077 rows=167 loops=1)
         Filter: (rank_in_year <= 3)
         Rows Removed by Filter: 1178
         Buffers: shared hit=12
 Planning:
   Buffers: shared hit=21
 Planning Time: 0.060 ms
 Execution Time: 0.120 ms
(12 rows)

Time: 0.290 ms
-- Q3: Undiscovered Gems (From DBT Mart) --
                                                          QUERY PLAN                                                           
-------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=5.22..5.35 rows=50 width=25) (actual time=0.031..0.035 rows=50 loops=1)
   Buffers: shared hit=1
   ->  Sort  (cost=5.22..5.47 rows=98 width=25) (actual time=0.030..0.032 rows=50 loops=1)
         Sort Key: song_hotttnesss DESC
         Sort Method: quicksort  Memory: 32kB
         Buffers: shared hit=1
         ->  Seq Scan on mart_undiscovered_gems  (cost=0.00..1.98 rows=98 width=25) (actual time=0.002..0.018 rows=98 loops=1)
               Buffers: shared hit=1
 Planning:
   Buffers: shared hit=14
 Planning Time: 0.031 ms
 Execution Time: 0.040 ms
(12 rows)

Time: 0.154 ms
-- Q4: Artist Profiling (From DBT Mart) --
                                                             QUERY PLAN                                                              
-------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=756.71..756.73 rows=10 width=99) (actual time=1.914..1.915 rows=10 loops=1)
   Buffers: shared hit=222
   ->  Sort  (cost=756.71..799.00 rows=16916 width=99) (actual time=1.914..1.915 rows=10 loops=1)
         Sort Key: total_listens DESC
         Sort Method: top-N heapsort  Memory: 26kB
         Buffers: shared hit=222
         ->  Seq Scan on mart_artist_profiles  (cost=0.00..391.16 rows=16916 width=99) (actual time=0.001..0.835 rows=16916 loops=1)
               Buffers: shared hit=222
 Planning:
   Buffers: shared hit=38
 Planning Time: 0.050 ms
 Execution Time: 1.919 ms
(12 rows)

Time: 2.055 ms
