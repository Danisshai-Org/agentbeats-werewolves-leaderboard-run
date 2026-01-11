-- Werewolf Arena - Villager Role Leaderboard
-- ==========================================
-- Rankings for performance as Villager/Seer/Doctor
-- Measures: detection (identifying werewolves), accusation accuracy

SELECT
    r.participant AS "Agent",
    ROUND(r.villager_elo) AS "Villager ELO",
    ROUND(r.villager_win_rate * 100, 1) AS "Win %",
    ROUND(r.detection_score * 100, 1) AS "Detection",
    ROUND(r.accusation_accuracy * 100, 1) AS "Accuse Acc %",
    r.games_as_villager AS "Games"
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY participant ORDER BY villager_elo DESC) AS rn
    FROM (
        SELECT
            res.participant,
            res.villager_elo,
            res.villager_win_rate,
            res.detection_score,
            res.accusation_accuracy,
            res.games_as_villager
        FROM results
        CROSS JOIN UNNEST(results.results) AS t(res)
        WHERE res.games_as_villager > 0
    )
) r
WHERE rn = 1
ORDER BY r.villager_elo DESC, r.villager_win_rate DESC;
