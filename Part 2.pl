grid([[r, e, d, e, e],
      [e, e, f, e, s],
      [d, e, e, e, d],
      [e, s, e, f, s]]).

cell(R, C, V) :-
    grid(G),
    nth1(R, G, Row),
    nth1(C, Row, V).

dims(Rows, Cols) :-
    grid(G),
    length(G, Rows),
    G = [First|_],
    length(First, Cols).

ok(R, C) :-
    dims(MaxR, MaxC),
    R >= 1, R =< MaxR,
    C >= 1, C =< MaxC,
    cell(R, C, V),
    V \= d,
    V \= f.

start(R, C) :-
    grid(G),
    nth1(R, G, Row),
    nth1(C, Row, r).

%collect all survivors positions from the grid
all_survivors(Ss) :-
    grid(G),
    findall((R,C), (nth1(R,G,Row), nth1(C,Row,s)), Ss).

is_survivor((R,C)) :- cell(R, C, s).

%moves
move((R,C), (NR,C)) :- NR is R-1, ok(NR,C).
move((R,C), (NR,C)) :- NR is R+1, ok(NR,C).
move((R,C), (R,NC)) :- NC is C-1, ok(R,NC).
move((R,C), (R,NC)) :- NC is C+1, ok(R,NC).


%heuristic
heuristic(st((R,C), Rescued, _), H) :-
    all_survivors(All),
    findall(D, (member(S, All),
                \+ member(S, Rescued),
                S = (SR,SC),
                D is abs(R-SR) + abs(C-SC)),
            Dists),
    (   Dists = []
    ->  H = 0
    ;   msort(Dists, [H|_])  
    ).


%open list operations
pop([H|T], H, T).

%insert a list of children into the sorted open list
push_all([], Open, Open).
push_all([K|Rest], Open, Final) :-
    insert(K, Open, Tmp),
    push_all(Rest, Tmp, Final).

%insert one node into its correct sorted position
insert(N, [], [N]) :- !.
insert([H1,S1,P1], [[H2,S2,P2]|T], [[H1,S1,P1],[H2,S2,P2]|T]) :-
    H1 =< H2, !.
insert(N, [X|T], [X|Rest]) :-
    insert(N, T, Rest).


%child generation
children(Node, Open, Closed, Kids) :-
    findall(K, next(Node, Open, Closed, K), Kids).

next([_, St, _], Open, Closed, [NH, NSt, St]) :-
    St = st(Pos, Rescued, Visited),
    move(Pos, NPos),
    \+ member(NPos, Visited),
    NewVisited = [NPos | Visited],
    (   is_survivor(NPos), \+ member(NPos, Rescued)
    ->  NewRescued = [NPos | Rescued]
    ;   NewRescued = Rescued
    ),
    NSt = st(NPos, NewRescued, NewVisited),
    \+ member([_, NSt, _], Open),
    \+ member([_, NSt, _], Closed),
    heuristic(NSt, NH).


%Greedy BFS
gbfs([], Closed, Best, Best, Closed) :- !.

gbfs(Open, Closed, BestSoFar, BestFinal, FC) :-
    pop(Open, Curr, TmpOpen),             
    Curr = [_, st(_, CurR, _), _],
    update_best(Curr, CurR, BestSoFar, NewBest),
    children(Curr, TmpOpen, Closed, Kids),  
    push_all(Kids, TmpOpen, NewOpen),      
    append(Closed, [Curr], NewClosed),     
    gbfs(NewOpen, NewClosed, NewBest, BestFinal, FC).

%update best if current node rescued more survivors
update_best(Curr, _, none, Curr) :- !.
update_best(Curr, CurR, Best, NewBest) :-
    Best = [_, st(_, BR, _), _],
    length(CurR, NC), length(BR, NB),
    (NC > NB -> NewBest = Curr ; NewBest = Best).


%rebuild path
build_path([_, st(Pos,_,_), null], _, [Pos]) :- !.
build_path([_, st(Pos,_,_), Par], Closed, Path) :-
    member([_, Par, GPar], Closed),
    build_path([_, Par, GPar], Closed, Pre),
    append(Pre, [Pos], Path).


%printing
show_path([]).
show_path([(R,C)]) :- format('(~w,~w)', [R,C]), nl, !.
show_path([(R,C)|T]) :- format('(~w,~w) -> ', [R,C]), show_path(T).


% entry point: ?- solve.
solve :-
    start(R, C),
    Pos = (R,C),
    (is_survivor(Pos) -> IR = [Pos] ; IR = []),
    Init = st(Pos, IR, [Pos]),
    heuristic(Init, H0),
    InitNode = [H0, Init, null],
    gbfs([InitNode], [], none, Best, FC),
    (   Best = none
    ->  write('No path found.'), nl
    ;   Best = [_, st(_, BR, _), _],
        build_path(Best, FC, Path),
        length(BR, NS),
        length(Path, L), Steps is L - 1,
        write('Path found: '), show_path(Path),
        format('Survivors rescued: ~w~n', [NS]),
        format('Number of steps: ~w~n', [Steps])
    ).