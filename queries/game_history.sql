-- Werewolf Arena - Game History
-- ==============================
-- Recent games for transparency and audit
-- Shows who played together and the outcomes

SELECT
    g.game_id AS "Game ID",
    g.timestamp AS "Date",
    g.werewolves AS "Werewolf Team",
    g.villagers AS "Villager Team",
    g.winner AS "Winner",
    g.rounds AS "Rounds"
FROM results
CROSS JOIN UNNEST(results.games) AS t(g)
ORDER BY g.timestamp DESC
LIMIT 50;
