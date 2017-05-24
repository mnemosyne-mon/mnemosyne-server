-- WITH
--   ts AS (
--     SELECT
--       generate_series AS start,
--       (generate_series + '1 min') AS stop,
--       (extract(epoch from generate_series) * 1000000000)::bigint AS start_ns,
--       (extract(epoch from generate_series + '1 min') * 1000000000)::bigint AS stop_ns
--     FROM generate_series(
--       date_trunc('minute', current_timestamp at time zone 'utc' - interval '30 min'),
--       current_timestamp at time zone 'utc',
--       '1 min'
--     )
--   ),
--   ls AS (
--     SELECT
--       generate_series AS min,
--       (generate_series + 10000) AS max
--     FROM generate_series(0, 500000, 10000)
--   ),
--   bk AS (
--     SELECT * FROM ts CROSS JOIN ls
--   ),
--   src AS (
--     SELECT * FROM traces
--     WHERE
--       traces.stop > (extract(
--         epoch from date_trunc('minute',
--           current_timestamp at time zone 'utc' - interval '30 min')) * 1000000000)::bigint
--       AND traces.stop <= (extract(
--         epoch from date_trunc('minute', current_timestamp at time zone 'utc')) * 1000000000)::bigint
--   )
-- SELECT
--   bk.start,
--   bk.stop,
--   bk.min,
--   bk.max,
--   COUNT(src.id)
-- FROM
--   bk
-- LEFT JOIN src ON
--   src.stop > bk.start_ns AND src.stop <= bk.stop_ns
-- AND
--   (src.stop - src.start) > bk.min AND (src.stop - src.start) <= bk.max
-- GROUP BY
--   bk.start, bk.stop, bk.min, bk.max
-- ORDER BY
--   bk.start, bk.min


-- WITH
--   ts AS (
--     SELECT
--       generate_series AS start,
--       (generate_series + '1 min') AS stop,
--       (extract(epoch from generate_series) * 1000000000)::bigint AS start_ns,
--       (extract(epoch from generate_series + '1 min') * 1000000000)::bigint AS stop_ns
--     FROM generate_series(
--       date_trunc('minute', current_timestamp at time zone 'utc' - interval '30 min'),
--       current_timestamp at time zone 'utc',
--       '1 min'
--     )
--   ),
--   ls AS (
--     SELECT
--       generate_series AS min,
--       (generate_series + 10000) AS max
--     FROM generate_series(0, 500000, 10000)
--   ),
--   src AS (
--     SELECT * FROM traces
--     WHERE
--       traces.stop > (extract(
--         epoch from date_trunc('minute',
--           current_timestamp at time zone 'utc' - interval '30 min'))::bigint * 1000000000)
--       AND traces.stop <= (extract(
--         epoch from date_trunc('minute', current_timestamp at time zone 'utc'))::bigint * 1000000000)
--   )
-- SELECT
--   ts.start,
--   ts.stop,
--   ls.min,
--   ls.max,
--   COUNT(src.id)
-- FROM
--   src
-- JOIN ts ON
--   src.stop > ts.start_ns AND src.stop <= ts.stop_ns
-- JOIN ls ON
--   (src.stop - src.start) > ls.min AND (src.stop - src.start) <= ls.max
-- GROUP BY
--   ts.start, ts.stop, ls.min, ls.max
-- ORDER BY
--   ts.start, ls.min


-- WITH
--   ts AS (
--     SELECT
--       generate_series AS start,
--       (generate_series + '1 min') AS stop,
--       (extract(epoch from generate_series) * 1000000000)::bigint AS start_ns,
--       (extract(epoch from generate_series + '1 min') * 1000000000)::bigint AS stop_ns
--     FROM generate_series(
--       date_trunc('minute', current_timestamp at time zone 'utc' - interval '30 min'),
--       current_timestamp at time zone 'utc',
--       '1 min'
--     )
--   ),
--   ls AS (
--     SELECT
--       generate_series AS min,
--       (generate_series + 10000) AS max
--     FROM generate_series(0, 500000, 10000)
--   ),
--   src AS (
--     SELECT * FROM traces
--     WHERE
--       traces.stop > (extract(
--         epoch from date_trunc('minute',
--           current_timestamp at time zone 'utc' - interval '30 min')) * 1000000000)::bigint
--       AND traces.stop <= (extract(
--         epoch from date_trunc('minute', current_timestamp at time zone 'utc')) * 1000000000)::bigint
--   )
-- SELECT
--   ts.start,
--   ts.stop,
--   ls.min,
--   ls.max,
--   COUNT(src.id)
-- FROM
--   src
-- JOIN ts ON
--   src.stop > ts.start_ns AND src.stop <= ts.stop_ns
-- JOIN ls ON
--   (src.stop - src.start) > ls.min AND (src.stop - src.start) <= ls.max
-- GROUP BY
--   ts.start, ts.stop, ls.min, ls.max
-- ORDER BY
--   ts.start, ls.min

--                                                                        QUERY PLAN
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
--  Sort  (cost=3915258821.60..3915258921.60 rows=40000 width=40) (actual time=97463.339..97463.497 rows=262 loops=1)
--    Sort Key: ts.start, ls.min
--    Sort Method: quicksort  Memory: 45kB
--    CTE ts
--      ->  Function Scan on generate_series  (cost=0.02..30.02 rows=1000 width=8) (actual time=0.031..0.157 rows=31 loops=1)
--    CTE ls
--      ->  Function Scan on generate_series generate_series_1  (cost=0.00..12.50 rows=1000 width=4) (actual time=0.011..0.109 rows=51 loops=1)
--    ->  HashAggregate  (cost=3915255321.53..3915255721.53 rows=40000 width=40) (actual time=97462.869..97463.121 rows=262 loops=1)
--          Group Key: ts.start, ls.min, ts.stop, ls.max
--          ->  Nested Loop  (cost=0.00..3705543593.76 rows=16776938222 width=40) (actual time=3405.175..97460.871 rows=2286 loops=1)
--                Join Filter: ((traces.stop > ts.start_ns) AND (traces.stop <= ts.stop_ns))
--                Rows Removed by Join Filter: 411564
--                ->  CTE Scan on ts  (cost=0.00..20.00 rows=1000 width=32) (actual time=0.034..0.219 rows=31 loops=1)
--                ->  Materialize  (cost=0.00..32410459.87 rows=150992444 width=32) (actual time=2.933..3135.037 rows=13350 loops=31)
--                      ->  Nested Loop  (cost=0.00..30623322.65 rows=150992444 width=32) (actual time=90.896..96918.072 rows=13350 loops=1)
--                            Join Filter: (((traces.stop - traces.start) > ls.min) AND ((traces.stop - traces.start) <= ls.max))
--                            Rows Removed by Join Filter: 69130869
--                            ->  CTE Scan on ls  (cost=0.00..20.00 rows=1000 width=8) (actual time=0.013..0.261 rows=51 loops=1)
--                            ->  Materialize  (cost=0.00..50729.98 rows=1358932 width=32) (actual time=0.001..885.809 rows=1355769 loops=51)
--                                  ->  Seq Scan on traces  (cost=0.00..43935.32 rows=1358932 width=32) (actual time=0.009..1007.821 rows=1355769 loops=1)
--  Planning time: 0.281 ms
--  Execution time: 97479.370 ms
-- (22 rows)







-- SELECT
--   (extract(epoch from generate_series) * 1000000000)::bigint,
--   generate_series AS start,
--   (generate_series + '1 min') AS stop
-- FROM generate_series(
--   date_trunc('minute', current_timestamp at time zone 'utc' - interval '30 min'),
--   current_timestamp at time zone 'utc',
--   '1 min'
-- )


-- SELECT
--   stop,
--   (extract(epoch from (current_timestamp at time zone 'UTC' - interval '1 sec')) * 1000000000)::bigint as s_0
--   -- t_bucket,
--   -- l_bucket,
--   -- COUNT(traces.id) AS count
-- FROM
--   traces
-- WHERE
--     traces.stop >= (extract(epoch from (current_timestamp at time zone 'UTC' - interval '1 sec')) * 1000000000)::bigint
-- --   AND
-- --     traces.stop < (extract(epoch from current_timestamp) * 100000000)
-- -- GROUP BY
-- --   t_bucket,
-- --   l_bucket


-- WITH
--   ts AS (
--     SELECT
--       generate_series AS start,
--       (generate_series + '1 min') AS stop,
--       (extract(epoch from generate_series) * 1000000000)::bigint AS start_ns,
--       (extract(epoch from generate_series + '1 min') * 1000000000)::bigint AS stop_ns
--     FROM generate_series(
--       date_trunc('minute', current_timestamp at time zone 'utc' - interval '30 min'),
--       current_timestamp at time zone 'utc',
--       '1 min'
--     )
--   ),
--   ls AS (
--     SELECT
--       generate_series AS min,
--       (generate_series + 10000) AS max
--     FROM generate_series(0, 500000, 10000)
--   ),
--   bk AS (
--     SELECT
--       start, stop, start_ns, stop_ns, min, max
--     FROM ts CROSS JOIN ls
--   )
-- SELECT
--   bk.start,
--   bk.stop,
--   bk.min,
--   bk.max,
--   COUNT(traces.id)
-- FROM
--   bk
-- LEFT JOIN traces ON
--     traces.stop > bk.start_ns AND traces.stop <= bk.stop_ns
--   AND
--     (traces.stop - traces.start) > bk.min AND (traces.stop - traces.start) <= bk.max
-- -- WHERE
-- --     traces.stop > MIN(ts.start_ns)
-- --   AND
-- --     traces.stop <= MAX(ts.stop_ns)
-- GROUP BY
--   bk.start, bk.stop, bk.min, bk.max
-- ORDER BY
--   bk.start, bk.min



WITH
  src AS (
    SELECT
      id,
      stop / 1000000000 * 60 AS ts,
      (stop - start) / 10000000 AS ls
    FROM traces
    WHERE
      traces.stop > (extract(
        epoch from date_trunc('minute',
          current_timestamp at time zone 'utc' - interval '30 min'))::bigint * 1000000000)
      AND traces.stop <= (extract(
        epoch from date_trunc('minute', current_timestamp at time zone 'utc'))::bigint * 1000000000)
  )
SELECT
  ts,
  ls,
  COUNT(src.id)
FROM
  src
GROUP BY
  ts, ls
ORDER BY
  ts, ls
