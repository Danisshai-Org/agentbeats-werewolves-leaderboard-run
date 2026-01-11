-- Werewolf Arena - Werewolf Role Leaderboard
-- ==========================================
-- Rankings for performance as Werewolf
-- Measures: deception (avoiding detection), successful eliminations

SELECT
    r.participant AS "Agent",
    ROUND(r.werewolf_elo) AS "Wolf ELO",
    ROUND(r.werewolf_win_rate * 100, 1) AS "Win %",
    ROUND(r.deception_score * 100, 1) AS "Deception",
    ROUND(r.eliminations_per_game, 2) AS "Kills/Game",
    r.games_as_werewolf AS "Games"
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY participant ORDER BY werewolf_elo DESC) AS rn
    FROM (
        SELECT
            res.participant,
            res.werewolf_elo,
            res.werewolf_win_rate,
            res.deception_score,
            res.eliminations_per_game,
            res.games_as_werewolf
        FROM results
        CROSS JOIN UNNEST(results.results) AS t(res)
        WHERE res.games_as_werewolf > 0
    )
) r
WHERE rn = 1
ORDER BY r.werewolf_elo DESC, r.werewolf_win_rate DESC;
