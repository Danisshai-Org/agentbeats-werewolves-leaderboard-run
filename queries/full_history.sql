-- DuckDB query for Full Assessment History
-- Shows all assessment results without deduplication

SELECT
    id,
    ROUND(elo_rating) AS "ELO",
    ROUND(aggregate_score * 100, 1) AS "Score",
    games_played AS "Games",
    ROUND(werewolf_win_rate * 100, 1) AS "Wolf Win %",
    ROUND(villager_win_rate * 100, 1) AS "Villager Win %",
    ROUND(deception_score * 100, 1) AS "Deception",
    ROUND(detection_score * 100, 1) AS "Detection"
FROM (
    SELECT
        results.participants.werewolf_player AS id,
        res.elo_rating AS elo_rating,
        res.aggregate_score AS aggregate_score,
        res.games_played AS games_played,
        res.werewolf_win_rate AS werewolf_win_rate,
        res.villager_win_rate AS villager_win_rate,
        res.deception_score AS deception_score,
        res.detection_score AS detection_score
    FROM results
    CROSS JOIN UNNEST(results.results) AS r(res)
    WHERE res.games_played > 0
)
ORDER BY elo_rating DESC, aggregate_score DESC;
