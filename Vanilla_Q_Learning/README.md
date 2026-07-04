# BC-TSP: Budget-Constrained Traveling Salesman Problem

Implementation of the algorithms from the paper:
**"Budget-Constrained Traveling Salesman Problem: a Cooperative Multi-Agent Reinforcement Learning Approach"**
https://csc.csudh.edu/btang/secon_2024_journal.pdf

---

## State of the Code

The core algorithms (Greedy 1, Greedy 2, P-MARL, Q-Learning) are all implemented and reflect the logic described in the paper. However, this codebase has not been actively maintained for some time, so **some parts may need debugging or minor fixes before they run cleanly end-to-end**. In particular:

- The batch loop in `main.java` (lines ~80–117) is commented out and may need adjustments — it was an earlier one-off data collection script and is not the primary way to generate figures.
- File paths for the data files (`src/Capital_Cities.txt`, `src/California_Cities.txt`) assume a specific working directory — if the project is opened in a different environment, these may need to be updated.
- The ILP code is fully commented out and non-functional in Java; it depends on IBM CPLEX and is only present for reference.
- `TableData.java` is the intended entry point for generating figure data and should work as-is, but its hyperparameter values (alpha, gamma, W, etc.) are set independently from `main.java` — double-check the constants at the top of each file are consistent before comparing output across them.

If something breaks, the algorithms themselves are sound — the issue is likely a path, a hardcoded value, or a commented-out block that needs to be restored.

---

## File Overview

| File | Purpose |
|------|---------|
| `main.java` | Q-Learning single-run entry point for 48 capital cities. Calculates distance in miles using Haversine formula. |
| `mainCoord.java` | Q-Learning single-run entry point for 620 California cities. Calculates distance using Euclidean formula in coordinate units. |
| `mainPMARL.java` | P-MARL single-run entry point for 48 capital cities. Calculates distance in miles using Haversine formula. |
| `mainPMARLCoord.java` | P-MARL single-run entry point for 620 California cities. Calculates distance using Euclidean formula in coordinate units. |
| `CityNode.java` | Represents a city with latitude, longitude, and prize. Computes pairwise distances using the Haversine formula (miles). |
| `CityNodeCoord.java` | Same as CityNode.java but computes pairwise distances using the Euclidean formula (coordinate units). Created to support the USA13509 TSP dataset. |
| `Agent.java` | Agent class used by P-MARL during the learning stage. Each agent holds its own graph copy, budget, current path, and prize total. |
| `Graph.java` | Adjacency matrix graph. Runs Floyd-Warshall on initialization so all shortest paths (including detours through intermediate cities) are precomputed. |
| `Exploration.java` | Hyperparameter grid search over trials, agents, alpha, gamma, and q0. Used to find the best P-MARL settings. |
| `TableData.java` | Batch runner for generating figure data. Loops over multiple cities, budgets, and agent counts. |
| `Capital_Cities.txt` | 48 continental US state capital cities used for 48-city experiments. Distance in miles. |
| `California_Cities.txt` | 620 California cities extracted from the USA13509 TSP benchmark dataset. Distance in coordinate units. Random prizes [1,100] assigned using fixed seed 12345. |

---

## Modifications from Original Codebase

The following changes were made to extend the original P-MARL implementation:

### Q-Learning Implementation
`main.java` has been modified from the original P-MARL to implement Q-Learning by:
- Setting number of agents M=1 (single agent)
- Adding reward value R back into the step-by-step Q-table update (Equation 8 in the paper)
- Removing the cooperative learning phase (lines 24-28 of Algorithm 3)

### Coordinate-Based Distance Calculation
`CityNodeCoord.java` replaces the Haversine formula with the Euclidean formula:
```java
// Original (Haversine - miles):
return d * kmToMile;

// New (Euclidean - coordinate units):
return Math.sqrt(Math.pow(city1.lat - city2.lat, 2) + Math.pow(city1.lon - city2.lon, 2));
```

### Infinite Loop Fix
A bug fix was applied to the roulette wheel selection in `getNextStateFromCurState()` in both Coord files. With large input sizes, floating point precision errors could prevent the while loop from terminating. The fix adds a bounds check and handles the case where all Q values are zero:
```java
// Added before normalization:
if (total == 0) {
    return feasible.get(rand.nextInt(feasible.size()));
}

// Added bounds check to while condition:
while (target > 0 && idx < feasible.size() - 1) {
```

### California Cities Dataset
620 California cities were extracted from the USA13509 TSPLIB benchmark dataset
(https://www.math.uwaterloo.ca/tsp/usa13509/usa13509.html).
Budgets for this dataset are in coordinate units. The estimated full tour length
is ~1,316,141 units, so budgets of 500,000 / 750,000 / 1,100,000 were used
(approximately 38%, 57%, and 84% of the full tour).

---

## Algorithms Implemented

### Q-Learning — `learnQ()` + `traverseQ()` in `main.java` / `mainCoord.java`
Single-agent Q-Learning implementation derived from P-MARL (Algorithm 3 from the paper).
- **Learning stage:** Single agent explores prize-collecting paths using the full Bellman update including reward value R(c,a).
- **Execution stage:** Salesman follows learned Q-table greedily from source to destination.
- Key difference from P-MARL: no cooperative learning phase, single agent only (M=1).

### Greedy Algorithm 1 — `traverseP()` in `main.java` / `TableData.java`
At each step, visits the budget-feasible unvisited node with the **largest prize**. Nodes are sorted once by prize at the start.

### Greedy Algorithm 2 — `traverseR()` in `main.java` / `TableData.java`
At each step, visits the budget-feasible unvisited node with the **best prize-to-distance ratio** (`prize / distance`), re-evaluated from the current position each step.

### P-MARL — `learnQ()` + `traverseQ()` in `mainPMARL.java` / `mainPMARLCoord.java`
Prize-driven Multi-Agent Reinforcement Learning (Algorithm 3 from the paper).
- **Learning stage:** Multiple agents independently explore prize-collecting paths using a prize-weighted action mechanism (`Q^δ × prize / distance^β`). After each episode, agents share results and cooperatively reinforce the highest-prize route found.
- **Execution stage:** The salesman follows the learned Q-table greedily from source to destination.
- Key hyperparameters (top of each file): `NUM_AGENTS`, `TRIALS`, `alpha`, `gamma`, `q0`, `W`.

### ILP — IBM CPLEX (external)
The ILP is not executed in Java. Instead, `printIlpArrays()` in `main.java` prints the **cost matrix** and **prize array** formatted for direct paste into IBM CPLEX Optimization Studio. Run `main.java` on the 10-city dataset and copy the printed arrays into CPLEX to get the optimal solution.

---

## How to Run

### 48 Capital Cities (miles)
1. Ensure `Capital_Cities.txt` is in your `src` folder
2. Use `main.java` for Q-Learning or `mainPMARL.java` for P-MARL
3. Budget is set in `askForUserInputs()` — currently hardcoded to 10,000 miles
4. Start and end city are currently hardcoded to `"Albany,NY"`
5. Compile all `.java` files and run the appropriate main file

### 620 California Cities (coordinate units)
1. Ensure `California_Cities.txt` is in your `src` folder
2. Use `mainCoord.java` for Q-Learning or `mainPMARLCoord.java` for P-MARL
3. Budget is set in `askForUserInputs()` — use 500000, 750000, or 1100000
4. Start and end city are set to `"SanDiegoArea_001"` by default
5. Compile all `.java` files alongside `CityNodeCoord.java` and run the appropriate main file

---

## Switching Between Network Sizes

Two things must be changed together:

**1. Change the filename** at the top of the relevant main file:
```java
// 48 cities (capital cities - miles)
static String fileName = "Capital_Cities.txt";

// 620 cities (California cities - coordinate units)
static String fileName = "California_Cities.txt";
```

**2. Update the number of cities:**
```java
// 48 cities
static int n = 48;

// 620 cities
static int n = 620;
```

**3. Update start and end city:**
```java
// 48 cities
begin = "Albany,NY";
end = "Albany,NY";

// 620 cities
begin = "SanDiegoArea_001";
end = "SanDiegoArea_001";
```

**4. Update the budget:**
```java
// 48 cities (miles)
budget = 10000;

// 620 cities (coordinate units)
budget = 500000; // or 750000 or 1100000
```

---

## Generating Figures

### Figure 9 — 48 Capital Cities, Q-Learning vs P-MARL, Prize and Distance
- Run `main.java` (Q-Learning) and `mainPMARL.java` (P-MARL) 10 times each at budgets of 4,000 / 6,000 / 8,000 / 10,000 miles
- Record prize collected and total distance for each run
- Compute average and 95% confidence interval across 10 runs
- Budget and distance are in **miles**

### Figure 10 — 620 California Cities, Q-Learning vs P-MARL, Prize and Runtime
- Run `mainCoord.java` (Q-Learning) and `mainPMARLCoord.java` (P-MARL) 10 times each at budgets of 500,000 / 750,000 / 1,100,000 coordinate units
- Record prize collected and runtime for each run
- Compute average and 95% confidence interval across 10 runs
- Budget and distance are in **coordinate units**

---

## Generating Plots with Gnuplot

The `gnuplot/` folder contains everything needed to reproduce the paper's plots:

| File type | Purpose |
|-----------|---------|
| `.dat` | Raw data (budget, algorithm values, error bars) |
| `.txt` | Gnuplot script that reads the `.dat` and produces the plot |
| `.eps` | Output plot generated by the script |

**To regenerate a plot:**
1. Collect 10 runs of data for each algorithm and budget
2. Compute averages and 95% confidence intervals
3. Update the corresponding `.dat` file with the new values
4. Run the gnuplot script: `gnuplot Fig9Prize.txt`

---

## Note on Ant-Q

The paper compares P-MARL against Ant-Q, but **only P-MARL is implemented here**. Ant-Q is prize-oblivious — it was originally designed to minimize travel distance across all nodes, not maximize prizes. The behavioral difference from P-MARL comes down to three small changes:

**1. Remove prize from action selection** (`getNextStateFromCurState`):
```java
// P-MARL
Math.pow(Q[s][u], delta) * aj.getPrize(u) / Math.pow(aj.weight(s, u), beta)

// Ant-Q
Math.pow(Q[s][u], delta) / Math.pow(aj.weight(s, u), beta)
```

**2. Select the shortest-distance agent instead of the highest-prize agent** (`learnQ`):
```java
// P-MARL
int mostFitIndex = findHighestPrize(aList);

// Ant-Q
int mostFitIndex = findShortestDistance(aList);
```

**3. Reinforce by distance instead of prize** (`learnQ` cooperative update):
```java
// P-MARL
R[path.get(v)][path.get(v + 1)] += (W / jStar.total_prize);

// Ant-Q
R[path.get(v)][path.get(v + 1)] += (W / jStar.total_wt);
```

---

## Data

All collected data for Q-Learning and P-MARL experiments is available at:
https://docs.google.com/document/d/1Jt1t0_cadSq8HisC2ZNFWOkSnc3d0LDGhE6DMZPJz6I/edit?usp=sharing

## Repository

All changes and commits are in the `research-2026` branch:
https://github.com/EthanTH04/research-2026.git
