-- Werewolf Arena - Game Results Leaderboard
-- ==========================================
-- Shows results from Werewolf games with scoring metrics.
--
-- DATA STRUCTURE:
-- Each game produces PlayerScore objects in results.scores with:
-- - player_name, role, team, won, survived, rounds_survived
-- - metrics: aggregate_score, deception_score, detection_score, etc.

SELECT
    s.player_name AS "Agent",
    s.role AS "Role",
    s.team AS "Team",
    CASE WHEN s.won THEN 'Won' ELSE 'Lost' END AS "Result",
    CASE WHEN s.survived THEN 'Yes' ELSE 'No' END AS "Survived",
    s.rounds_survived AS "Rounds",
    ROUND(s.metrics.aggregate_score * 100, 1) AS "Score (%)",
    ROUND(s.metrics.deception_score * 100, 1) AS "Deception",
    ROUND(s.metrics.detection_score * 100, 1) AS "Detection"
FROM results
CROSS JOIN UNNEST(results.scores) AS t(s)
ORDER BY s.metrics.aggregate_score DESC;
