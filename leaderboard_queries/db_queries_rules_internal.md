Great — now that we’ve found the **lowest-common-denominator that actually works**, we can formalize the **rules**.
Think of this as **“DuckDB-Lite / Sandbox Mode SQL”**.

Below is the **exact mental model** you should follow when writing queries in your environment.

---

# 🦆 DuckDB (Lite / Sandbox) Query Rules

These rules are derived **empirically** from what works and what fails in your setup.

---

## 1️⃣ Only trust this shape (copy it mentally)

```sql
FROM results
CROSS JOIN UNNEST(results.results) AS r(res)
```

### Rules

* `results` = the auto-loaded JSON file
* `results.results` = **array only**
* `res` = **one JSON object per row**
* ❌ Never UNNEST anything inside `res`

✅ **Good**

```sql
res.pass_rate
res.rounds_played
```

❌ **Bad**

```sql
res.scores
res.game_log
res.metrics.aggregate_score
```

---

## 2️⃣ Only access **top-level scalar fields** of `res`

Allowed field types:

* `STRING`
* `INTEGER`
* `DOUBLE`
* `NULL`

### Safe examples

```sql
res.pass_rate
res.time_used
res.rounds_played
res.winner
res.difficulty
```

### Unsafe examples

```sql
res.scores          -- array
res.metrics         -- struct
res.task_rewards    -- map/struct
```

---

## 3️⃣ Participant IDs must be **static keys**

This is critical.

### ✅ Works

```sql
results.participants.Player_1
results.participants.riddle_solver
```

### ❌ Never works

```sql
results.participants[s.player_name]
results.participants[player]
```

👉 **Rule:**
If the key isn’t known at query-authoring time, DuckDB Lite cannot bind it.

---

## 4️⃣ Alias scope is strict (no leaking)

Every column must be **fully qualified**.

### ✅ Correct

```sql
res.pass_rate
res.rounds_played
```

### ❌ Incorrect

```sql
pass_rate
rounds_played
```

Aliases never float upward.

---

## 5️⃣ Aggregations must be **simple**

### Safe

```sql
COUNT(*)
AVG(res.time_used)
SUM(res.final_score)
```

### Risky / often broken

```sql
SUM(res.won)                  -- boolean
SUM(CASE WHEN ...)            -- sometimes fails
```

💡 If in doubt, use `COUNT(*)` or `AVG(number)`.

---

## 6️⃣ Window functions: allowed but fragile

### Works (as you saw)

```sql
ROW_NUMBER() OVER (
  PARTITION BY id
  ORDER BY res.pass_rate DESC
)
```

### Rules

* Use **only on scalars**
* Never reference nested fields
* Keep ORDER BY simple

---

## 7️⃣ WHERE clauses must be defensive

### ✅ Safe

```sql
WHERE res.pass_rate IS NOT NULL
WHERE res.difficulty = 'medium'
```

### ❌ Unsafe

```sql
WHERE res.scores[0].won = true
```

---

## 8️⃣ ORDER BY only selected columns

### ✅ Good

```sql
ORDER BY pass_rate DESC
```

### ❌ Bad

```sql
ORDER BY res.pass_rate DESC
```

Once aliased, always sort by the alias.

---

## 9️⃣ One UNNEST per query (hard rule)

You get **one**:

```sql
CROSS JOIN UNNEST(results.results)
```

More than one = binder panic.

---

## 🔟 When in doubt, fall back to this template

This **never fails**:

```sql
SELECT
  results.participants.<STATIC_KEY> AS id,
  COUNT(*) AS metric
FROM results
CROSS JOIN UNNEST(results.results) AS r(res)
GROUP BY id;
```

---

# 🧠 Mental Model (important)

Your DuckDB is **not** a JSON engine.
It is:

> **A row flattener with limited SQL**

If you treat JSON as:

* “Already flattened”
* “Scalar only”
* “No dynamic structure”

…it will behave perfectly.

---

## ✅ Recommended Workflow

1. Start with `COUNT(*)`
2. Add **one scalar column**
3. Test
4. Repeat

If something breaks → you crossed a rule.

---

If you want, next I can:

* Turn this into a **checklist**
* Generate a **query linter**
* Give you **safe templates per leaderboard type**

Just say 👍
