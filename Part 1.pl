%grid
grid([[r, e, d, e, e],
      [e, e, f, e, s],
      [d, e, e, e, e],
      [e, s, e, f, e]]).

%get the value at (R,C)
cell(R, C, V) :-
    grid(G),
    nth1(R, G, Row),
    nth1(C, Row, V).

% grid dimensions
dims(Rows, Cols) :-
    grid(G),
    length(G, Rows),
    G = [First|_],
    length(First, Cols).

%can the robot step on (R,C)?
ok(R, C) :-
    dims(MaxR, MaxC),
    R >= 1, R =< MaxR,
    C >= 1, C =< MaxC,
    cell(R, C, V),
    V \= d,
    V \= f.

%where does the robot start?
start(R, C) :-
    grid(G),
    nth1(R, G, Row),
    nth1(C, Row, r).

%is (R,C) a survivor cell?
survivor(R, C) :- cell(R, C, s).


%moves

move((R,C), (NR,C)) :- NR is R-1, ok(NR,C).   % up
move((R,C), (NR,C)) :- NR is R+1, ok(NR,C).   % down
move((R,C), (R,NC)) :- NC is C-1, ok(R,NC).   % left
move((R,C), (R,NC)) :- NC is C+1, ok(R,NC).   % right


%open list operations
pop([H|T], H, T).
push(Kids, Open, New) :- append(Open, Kids, New).


% child generation
children(Node, Open, Closed, Kids) :-
    findall(K, next(Node, Open, Closed, K), Kids).

next([S,_], Open, Closed, [NS,S]) :-
    move(S, NS),
    \+ member([NS,_], Open),
    \+ member([NS,_], Closed).

%bfs(Open, Closed, GoalNode, FinalClosed)
%found the goal: front of open list is a survivor
bfs(Open, Closed, Goal, Closed) :-
    pop(Open, Curr, _),
    Curr = [(R,C),_],
    survivor(R, C), !,
    Goal = Curr.

%not goal: expand and keep searching
bfs(Open, Closed, Goal, FC) :-
    pop(Open, Curr, TmpOpen),
    children(Curr, TmpOpen, Closed, Kids),
    push(Kids, TmpOpen, NewOpen),
    append(Closed, [Curr], NewClosed),
    bfs(NewOpen, NewClosed, Goal, FC).


%rebuild the path from goal back to start

%base: reached root (no parent)
build_path([S, null], _, [S]) :- !.
build_path([S, Par], Closed, Path) :-
    member([Par, GPar], Closed),
    build_path([Par, GPar], Closed, Pre),
    append(Pre, [S], Path).


%printing
show_path([]).
show_path([(R,C)]) :- format('(~w,~w)', [R,C]), nl, !.
show_path([(R,C)|T]) :- format('(~w,~w) -> ', [R,C]), show_path(T).


%entry point: ?- solve.
solve :-
    start(R, C),
    Init = [(R,C), null],
    (   bfs([Init], [], Goal, FC)
    ->  build_path(Goal, FC, Path),
        length(Path, L),
        Steps is L - 1,
        Bat is 100 - Steps * 10,
        (   Bat < 0
        ->  write('No path found.'), nl
        ;   write('Path found: '), show_path(Path),
            format('Number of steps: ~w~n', [Steps]),
            format('Remaining Battery: ~w%~n', [Bat])
        )
    ;   write('No path found.'), nl
    ).