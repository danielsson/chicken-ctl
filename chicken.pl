% CHICKEN - The CTL Heliotropic model Interpreter ChecKEr, New version 
% Written by Lovisa Runhome and Mattias Danielsson, 2013-12-19



verify(Input) :-
see(Input), read(T), read(L), read(S), read(F), seen,
check(T, L, S, [], F).

% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.


check(T, L, S, _, and(F,G)) :- 
	check(T, L, S, [], F),
	check(T, L, S, [], G).


check(T, L, S, _, or(F, G)) :-
	check(T, L, S, [], F);
	check(T, L, S, [], G).


check(_, L, S, _, neg(X)) :-
	extract(S, L, Labels),
	not(member(X, Labels)).


check(T, L, S, [], ax(X)) :-
	extract(S, T, Children),
	check_ax(T, L, S, [], X, Children).


check(T, L, S, [], ex(X)) :-
	extract(S, T, Children),
	check_ex(T, L, S, [], X, Children).


check(_, _, S, Prev, ag(_)) :- %AG 1
	member(S, Prev).


check(T, L, S, Prev, ag(X)) :- %AG 2
	not(member(S, Prev)),
	extract(S, T, Children),

	check(T, L, S, [], X), % Must be true in this state
	!,
	check_ag(T, L, S, Prev, X, Children). % And in all children and their children
	

check(T, L, S, Prev, ef(X)) :- % EF 1
	not(member(S, Prev)),
	check(T, L, S, [], X).


check(T, L, S, Prev, ef(X)) :- % EF 2
	not(member(S, Prev)),
	extract(S, T, Children),

	check_ef(T, L, S, Prev, X, Children).


check(_, _, S, Prev, eg(_)) :- %EG 1
	member(S, Prev).

check(T, L, S, Prev, eg(X)) :- %EG 2
	not(member(S, Prev)),

	check(T, L, S, [], X),

	extract(S, T, Children),
	check_eg(T, L, S, Prev, X, Children).
	

check(T, L, S, Prev, af(X)) :- %AF 1
	not(member(S, Prev)),
	check(T, L, S, [], X).


check(T, L, S, Prev, af(X)) :- %AF 2
	not(member(S, Prev)),
	extract(S, T, Children),
	check_af(T, L, S, Prev, X, Children).


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
%Check eventual atoms
check(_, L, S, _, X) :-
	extract(S, L, Labels),
	member(X, Labels).

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %

check_ef(T, L, S, Prev, X, [Child | Children]) :-
	check(T, L, Child, [S | Prev], ef(X));
	check_ef(T, L, S, Prev, X, Children).

check_af(T, L, S, Prev, X, [Child | []]) :-
	check(T, L, Child, [S | Prev], af(X)).

check_af(T, L, S, Prev, X, [Child | Children]) :-
	check(T, L, Child, [S | Prev], af(X)),
	!,
	check_af(T, L, S, Prev, X, Children).

check_eg(T, L, S, Prev, X, [Child | []]) :-
	check(T, L, Child, [S | Prev], eg(X)).

check_eg(T, L, S, Prev, X, [Child | Children]) :-
	check(T, L, Child, [S | Prev], eg(X));
	check_eg(T, L, S, Prev, X, Children).

check_ax(T, L, _, Prev, X, [Child]) :-
	check(T, L, Child, Prev, X).

check_ax(T, L, S, Prev, X, [Child | Children]) :-
	check(T, L, Child, Prev, X),
	!,
	check_ax(T, L, S, Prev, X, Children).

check_ag(T, L, S, Prev, X, [Child]) :-
	check(T, L, Child, [S | Prev], ag(X)).

check_ag(T, L, S, Prev, X, [Child | Children]) :-
	check(T, L, Child, [S | Prev], ag(X)),
	!,
	check_ag(T, L, S, Prev, X, Children).

check_ex(T, L, S, Prev, X, [Child | Children]) :-
	check(T, L, Child, Prev, X);
	check_ex(T, L, S, Prev, X, Children).


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% Get list of values given a key(state).
extract(State, [[State, Values]| _],  Values) :- !.

extract(State, [_|L], Values) :-
	extract(State, L, Values).
