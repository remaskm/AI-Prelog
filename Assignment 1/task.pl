% TASK 1 

my_member(X, [X|_]).
my_member(X, [_|T]) :- my_member(X, T).


all_books(L) :- all_books([], L).

all_books(Acc, Acc) :- \+ (book(B, _), \+ my_member(B, Acc)).

all_books(Acc, L) :-
    book(B, _),
    \+ my_member(B, Acc),
    all_books([B|Acc], L).


borrowed_by(_, [], []).

borrowed_by(Student, [H|T], [H|Rest]) :-
    borrowed(Student, H), !,
    borrowed_by(Student, T, Rest).

borrowed_by(Student, [_|T], Rest) :-
    borrowed_by(Student, T, Rest).

% main predict
books_borrowed_by_student(Student, L) :-
    all_books(AllBooks),
    borrowed_by(Student, AllBooks, L), !.



% TASK 2 

all_students(L) :- all_students([], L).
all_students(Acc, Acc) :- \+ (student(S, _), \+ my_member(S, Acc)).
all_students(Acc, L) :-
    student(S, _),
    \+ my_member(S, Acc),
    all_students([S|Acc], L).

count_borrowed(_, [], 0).
count_borrowed(Book, [H|T], N) :-
    borrowed(H, Book), !,
    count_borrowed(Book, T, N1),
    N is N1 + 1.
count_borrowed(Book, [_|T], N) :-
    count_borrowed(Book, T, N).

% main predict
borrowers_count(Book, N) :-
    all_students(Students),
    count_borrowed(Book, Students, N), !.



% TASK 3

max_book([], Best, _, Best).
max_book([H|T], CurrentBest, CurrentMax, Result) :-
    borrowers_count(H, Count),
    Count > CurrentMax, !,
    max_book(T, H, Count, Result).
max_book([_|T], CurrentBest, CurrentMax, Result) :-
    max_book(T, CurrentBest, CurrentMax, Result).

%main predict
most_borrowed_book(B) :-
    all_books([First|Rest]),
    borrowers_count(First, FirstCount),
    max_book(Rest, First, FirstCount, B), !.



% TASK 4 

book_ratings(_, [], []).
book_ratings(Book, [H|T], [(H, Score)|Rest]) :-
    rating(H, Book, Score), !,
    book_ratings(Book, T, Rest).
book_ratings(Book, [_|T], Rest) :-
    book_ratings(Book, T, Rest).

%main predict
ratings_of_book(Book, L) :-
    all_students(Students),
    book_ratings(Book, Students, L), !.



% TASK 5

my_append([], L, L).
my_append([H|T], L2, [H|NT]) :- my_append(T, L2, NT).

student_ratings(_, [], []).
student_ratings(Student, [Book|T], [(Student,Score)|Rest]) :-
    rating(Student, Book, Score), !,
    student_ratings(Student, T, Rest).
student_ratings(Student, [_|T], Rest) :-
    student_ratings(Student, T, Rest).

all_ratings([], _, []).
all_ratings([S|T], Books, Pairs) :-
    student_ratings(S, Books, SPairs),
    all_ratings(T, Books, TPairs),
    my_append(SPairs, TPairs, Pairs).

max_score([], Best, _, Best).
max_score([(S, Score)|T], _, CurrentMax, Result) :-
    Score > CurrentMax, !,
    max_score(T, S, Score, Result).
max_score([_|T], CurrentBest, CurrentMax, Result) :-
    max_score(T, CurrentBest, CurrentMax, Result).

%main predict
top_reviewer(Student) :-
    all_students(Students),
    all_books(Books),
    all_ratings(Students, Books, [(FS, FScore)|Rest]),
    max_score(Rest, FS, FScore, Student), !.



% TASK 6 

all_topics([], []).
all_topics([Book|Rest], Merged) :-
    topics(Book, T),
    all_topics(Rest, RestTopics),
    my_append(T, RestTopics, Merged).

count_occurrences(_, [], 0).
count_occurrences(X, [X|T], N) :-
    !,
    count_occurrences(X, T, N1),
    N is N1 + 1.
count_occurrences(X, [_|T], N) :-
    count_occurrences(X, T, N).

max_freq_topic([], _, Best, _, Best).
max_freq_topic([H|T], AllTopics, CurrentBest, CurrentMax, Result) :-
    count_occurrences(H, AllTopics, Count),
    Count > CurrentMax, !,
    max_freq_topic(T, AllTopics, H, Count, Result).
max_freq_topic([_|T], AllTopics, CurrentBest, CurrentMax, Result) :-
    max_freq_topic(T, AllTopics, CurrentBest, CurrentMax, Result).

%main predict
most_common_topic_for_student(Student, Topic) :-
    books_borrowed_by_student(Student, Books),   
    all_topics(Books, AllTopics),               
    AllTopics = [First|_],
    max_freq_topic(AllTopics, AllTopics, First, 0, Topic), !.

