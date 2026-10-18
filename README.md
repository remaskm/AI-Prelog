# AI-Prelog

Two Prolog assignments from an Artificial Intelligence course. The first is a knowledge-base and list-processing exercise on a library system. The second is a pair of search problems (BFS and Greedy Best-First Search) for a rescue robot on a grid.

Tested with [SWI-Prolog](https://www.swi-prolog.org/).

## Contents

```
AI-Prelog/
├── AI - 1/
│   ├── Assignment 1.pl     # rules / predicates for the six tasks
│   └── library_data.pl     # facts: students, books, borrowing, topics, ratings
└── AI - 2/
    ├── Part 1.pl           # Breadth-First Search: reach the nearest survivor
    └── Part 2.pl           # Greedy Best-First Search: rescue as many survivors as possible
```

---

## Assignment 1: Library Knowledge Base

The facts in `library_data.pl` describe 7 students, 4 books and who borrowed and rated what:

| Predicate | Meaning |
|-----------|---------|
| `student(Name, Year)` | A student and their year |
| `book(Title, Author)` | A book and its author |
| `borrowed(Student, Book)` | A borrowing record |
| `topics(Book, TopicsList)` | The topics a book covers |
| `rating(Student, Book, Score)` | A student's score for a book |

`Assignment 1.pl` implements these queries without relying on `findall`/`setof`. It uses its own list helpers such as `my_member` and `my_append`, plus recursion and accumulators.

| Task | Predicate | Description |
|------|-----------|-------------|
| 1 | `books_borrowed_by_student(Student, List)` | All books borrowed by a student |
| 2 | `borrowers_count(Book, N)` | How many students borrowed a book |
| 3 | `most_borrowed_book(Book)` | The book with the most borrowers |
| 4 | `ratings_of_book(Book, List)` | `(Student, Score)` pairs for a book |
| 5 | `top_reviewer(Student)` | The student who gave the highest single rating |
| 6 | `most_common_topic_for_student(Student, Topic)` | The most frequent topic across the books a student borrowed |

### Run

Load both files together:

```bash
swipl -s "AI - 1/Assignment 1.pl" -s "AI - 1/library_data.pl"
```

Example queries:

```prolog
?- books_borrowed_by_student(mona, L).
?- borrowers_count(recursion_in_depth, N).
?- most_borrowed_book(B).
?- ratings_of_book(ai_intro, L).
?- top_reviewer(S).
?- most_common_topic_for_student(ali, T).
```

---

## Assignment 2: Rescue Robot Search

A robot on a grid has to find survivors. Each grid is a list of rows using these symbols:

| Symbol | Meaning |
|--------|---------|
| `r` | Robot start |
| `e` | Empty cell (walkable) |
| `s` | Survivor |
| `d`, `f` | Blocked cells (the robot cannot enter) |

The robot moves up, down, left or right. Coordinates are printed as `(Row,Column)`, starting at `(1,1)`.

### Part 1: Breadth-First Search (`Part 1.pl`)

Finds the **shortest path from the robot to the nearest survivor**.

- BFS with an open list (queue) and a closed list; each node stores its parent so the path can be rebuilt.
- Each step costs 10% battery from a full 100%. If the path would drain the battery below 0, it reports no path.
- Prints the path, the number of steps and the remaining battery.

```bash
swipl -s "AI - 2/Part 1.pl"
```
```prolog
?- solve.
```

### Part 2: Greedy Best-First Search (`Part 2.pl`)

Explores the grid to **rescue as many survivors as possible**.

- The open list is kept sorted by a heuristic: the **Manhattan distance to the closest survivor that hasn't been rescued yet**.
- Each state tracks the current position, the survivors rescued so far and the visited cells.
- The search keeps the best node seen, meaning the one with the most survivors rescued, and rebuilds the path to it.
- Prints the path, the number of survivors rescued and the number of steps.

The grid in this file contains three survivors.

```bash
swipl -s "AI - 2/Part 2.pl"
```
```prolog
?- solve.
```

### Changing the grid

Edit the `grid/1` fact at the top of `Part 1.pl` or `Part 2.pl`. The two parts define predicates with the same names, so load only one at a time.

## Notes

- The two assignments are independent and don't share code.
