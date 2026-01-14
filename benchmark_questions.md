# Werewolf Arena Benchmark - Open Questions & Potential Problems

This document identifies potential issues, criticisms, and open questions that need consideration for the Werewolf Arena benchmark design.

---

## 1. Player Count Problem

### Current Situation
- Original paper uses **8 players**
- Current implementation supports **5-8 players**
- Current queries only map **5 players**

### Potential Problems

**Variable player count creates unfair comparisons:**
- A werewolf in a 5-player game (1 wolf vs 4 villagers) faces different odds than in an 8-player game (2 wolves vs 6 villagers)
- Win rates are not comparable across different player counts
- ELO calculations become meaningless if game difficulty varies

**Statistical issues with different configurations:**
| Players | Werewolves | Wolf % | Game Dynamics |
|---------|------------|--------|---------------|
| 5 | 1 | 20% | Solo wolf, no coordination |
| 6 | 1 | 17% | Even harder for wolf |
| 7 | 2 | 29% | Wolf coordination possible |
| 8 | 2 | 25% | Paper's configuration |

**Questions:**
- Should player count be fixed or flexible?
- If fixed, which count and why?
- How do we handle historical data from different configurations?

---

## 2. Role Assignment Fairness

### Potential Problems

**Random role assignment creates variance:**
- An agent might get werewolf 80% of the time by chance
- Another agent might never play werewolf
- This skews ELO and skill assessment

**Special roles have outsized impact:**
- A bad Seer can doom the villager team
- A good Doctor can single-handedly save games
- Should these high-impact roles be evaluated separately?

**Questions:**
- Should role assignment be balanced (equal werewolf/villager games)?
- Should Seer/Doctor performance be weighted differently?
- How many games needed to average out role luck?

---

## 3. Agent Submission Model Concerns

### Current Model: One Agent, All Roles
An agent must play werewolf, seer, doctor, and villager.

**Problems:**
- Conflicting optimization targets (deception vs detection)
- Complex to develop and debug
- Hard to identify which role is weak

### Alternative: Specialized Agents
Participants submit separate wolf and villager agents.

**Problems:**
- Doesn't test adaptability
- Seer/Doctor become uncontrolled variables
- Who provides the Seer/Doctor agents?

### If Benchmark Provides Seer/Doctor

**Problems:**
- Baseline quality affects all games
- If baseline is too good → wolves always lose
- If baseline is too bad → wolves always win
- Participants can't showcase Seer/Doctor skills
- Reduces what the benchmark actually measures

**Questions:**
- What does the benchmark actually want to measure?
- Is role flexibility part of the evaluation or noise?
- Who decides what "good" Seer/Doctor behavior looks like?

---

## 4. Game Composition Issues

### Who Plays Against Whom?

**Problem: Self-play**
If one participant's wolves play against their own villagers:
- They might optimize for collusion
- Doesn't test against diverse strategies
- Not representative of real competition

**Problem: Cross-play matchmaking**
If Participant A's wolves play against Participant B's villagers:
- Need enough participants for matchmaking
- Some matchups might be inherently unfair
- Order effects (who plays first?)

**Problem: Statistical validity**
- How many games per matchup?
- How to handle unequal number of games?
- Round-robin vs random sampling?

**Questions:**
- What is the minimum number of participants needed?
- How do we ensure fair matchup distribution?
- Should head-to-head records be tracked?

---

## 5. ELO System Limitations

### Current Implementation Problems

**Simplified ELO doesn't consider opponent strength:**
```
Current: +25 for any win, -25 for any loss
Problem: Beating a 1500 ELO agent = Beating a 800 ELO agent
```

**Team-based games complicate individual ELO:**
- Did the werewolf win because they're good, or because villagers were bad?
- How to attribute team success to individuals?

**Role-specific ELO fragmentation:**
- Separate Wolf ELO and Villager ELO
- But what if someone only plays 2 games as wolf?
- Small sample sizes make role-specific ELO unreliable

**Questions:**
- Is ELO the right metric for team-based social deduction?
- Should we use a different rating system (TrueSkill, Glicko)?
- How to handle uncertainty in ratings?

---

## 6. Statistical Validity Concerns

### Sample Size Requirements

**Problem: High variance games**
- Social deduction has inherent randomness
- One unlucky vote can flip entire game
- Need many games to assess true skill

**Estimated requirements:**
- For 95% confidence: ~50+ games per agent
- For role-specific stats: ~20+ games per role
- Current data: Only 2 games total

### Confounding Variables

**Uncontrolled factors affecting results:**
- LLM API response variability
- Time of day (API load)
- Random seed differences
- Order of speaking in debates

**Questions:**
- How do we control for API variability?
- Should we require deterministic agents?
- How do we report confidence intervals?

---

## 7. Potential Criticisms & Attack Vectors

### Methodological Criticisms

| Criticism | Explanation |
|-----------|-------------|
| **Not generalizable** | Werewolf skill may not transfer to other tasks |
| **Game-specific overfitting** | Agents optimized for Werewolf rules only |
| **No human baseline** | Can't compare to human performance |
| **Artificial constraints** | Real social deduction is more complex |
| **Cherry-picked metrics** | Deception/detection scores are arbitrary |

### Gaming the System

| Attack | Explanation |
|--------|-------------|
| **Prompt injection** | Malicious prompts to confuse other agents |
| **Collusion signals** | Hidden coordination between wolf agents |
| **Exploiting baseline** | If Seer/Doctor are predictable, exploit patterns |
| **Sybil submissions** | Multiple accounts to manipulate matchups |
| **API fingerprinting** | Identifying opponent model by response patterns |

### Fairness Criticisms

| Criticism | Explanation |
|-----------|-------------|
| **Model size bias** | GPT-4 vs GPT-3.5 is unfair comparison |
| **Cost barrier** | Running 50+ games is expensive |
| **Access inequality** | Not everyone has same API access |
| **Compute advantage** | Faster inference = better bidding |

---

## 8. Data & Migration Concerns

### Current Data Incompatibility

**Problems with existing results:**
- Generated with 5-player configuration
- Queries hardcoded for 5 players
- Role distribution doesn't match paper
- ELO meaningless if rules change

**Questions:**
- Delete all data and start fresh?
- Archive old data for reference?
- How to version the benchmark format?

---

## 9. Technical Implementation Gaps

### Unresolved Technical Questions

| Area | Question |
|------|----------|
| **Timestamps** | How to order games chronologically without filename access? |
| **Agent crashes** | What happens if an agent times out mid-game? |
| **Rate limiting** | How to handle API rate limits during games? |
| **Reproducibility** | Can games be replayed with same results? |
| **Logging** | What level of detail to store for analysis? |

---

## 10. Scope & Purpose Questions

### Fundamental Questions Not Yet Answered

1. **What exactly is this benchmark measuring?**
   - General LLM capability?
   - Social reasoning specifically?
   - Deception/detection skills?
   - Multi-agent coordination?

2. **Who is the target audience?**
   - Academic researchers?
   - AI companies?
   - Hobbyists?

3. **What decisions should the benchmark inform?**
   - Model selection?
   - Training improvements?
   - Safety evaluations?

4. **How does this relate to AI safety?**
   - Does good deception skill indicate alignment risk?
   - Should we be benchmarking deception at all?

---

## Summary: Key Unresolved Issues

### Must Address Before Launch
- [ ] Fixed vs variable player count
- [ ] Role assignment fairness
- [ ] Agent submission format (1 vs 2 agents)
- [ ] Game composition (self-play vs cross-play)
- [ ] Minimum games for statistical validity

### Should Address
- [ ] ELO system appropriateness
- [ ] Baseline agent design (if providing Seer/Doctor)
- [ ] Anti-gaming measures
- [ ] Reproducibility guarantees

### Worth Considering
- [ ] Human baseline comparison
- [ ] Cost/accessibility concerns
- [ ] Model size categorization
- [ ] Long-term benchmark maintenance
