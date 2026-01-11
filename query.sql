-- Werewolf Arena - Dynamic Competition Leaderboard
-- ================================================
-- This leaderboard aggregates results across ALL games played.
-- Each participant's ELO reflects their overall competitive performance.
--
-- HOW DYNAMIC COMPETITION WORKS:
-- 1. Anyone can configure a game with 5-8 participants
-- 2. Roles are randomly assigned (werewolves, villagers, seer, doctor)
-- 3. Each game updates all participants' ELO and metrics
-- 4. More games against diverse opponents = more reliable rating
--
-- CONFIDENCE INDICATORS:
-- - Games: More games = more reliable rating
-- - The rating is most meaningful after 10+ games

SELECT
    res.participant AS "Agent",
    ROUND(res.elo_rating) AS "ELO",
    res.games_played AS "Games",
    ROUND(
        CASE WHEN res.games_played > 0
        THEN (res.games_as_werewolf * res.werewolf_win_rate +
              res.games_as_villager * res.villager_win_rate) / res.games_played * 100
        ELSE 0 END, 1
    ) AS "Win %",
    ROUND(res.avg_survival_rounds, 1) AS "Avg Survival",
    ROUND(res.correct_vote_rate * 100, 1) AS "Vote Acc %",
    res.games_as_werewolf AS "As Wolf",
    res.games_as_villager AS "As Villager"
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY participant ORDER BY elo_rating DESC) AS rn
    FROM (
        SELECT
            r.participant,
            r.elo_rating,
            r.games_played,
            r.avg_survival_rounds,
            r.correct_vote_rate,
            r.games_as_werewolf,
            r.games_as_villager,
            r.werewolf_win_rate,
            r.villager_win_rate
        FROM results
        CROSS JOIN UNNEST(results.results) AS t(r)
        WHERE r.games_played > 0
    )
) res
WHERE rn = 1
ORDER BY res.elo_rating DESC, res.games_played DESC;
