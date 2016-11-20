-module('clojerl.Range').

-include("clojerl.hrl").

-behavior('clojerl.Counted').
-behavior('clojerl.IColl').
-behavior('clojerl.IEquiv').
-behavior('clojerl.IHash').
-behavior('clojerl.IMeta').
-behavior('clojerl.ISeq').
-behavior('clojerl.ISequential').
-behavior('clojerl.Seqable').
-behavior('clojerl.Stringable').

-export([?CONSTRUCTOR/3]).

-export([count/1]).
-export([ cons/2
        , empty/1
        ]).
-export([equiv/2]).
-export([hash/1]).
-export([ meta/1
        , with_meta/2
        ]).
-export([ first/1
        , next/1
        , more/1
        ]).
-export(['_'/1]).
-export([ seq/1
        , to_list/1
        ]).
-export([str/1]).

-type type() :: #?TYPE{}.

-spec ?CONSTRUCTOR(integer(), integer(), integer()) -> type().
?CONSTRUCTOR(Start, End, Step) when Step >= 0, End < Start;
                                    Step < 0, Start < End ->
  [];
?CONSTRUCTOR(Start, End, Step) ->
  #?TYPE{data = {Start, End, Step}}.

%%------------------------------------------------------------------------------
%% Protocols
%%------------------------------------------------------------------------------

count(#?TYPE{name = ?M, data = {Start, End, Step}}) ->
  (End - Start + Step) div Step.

cons(#?TYPE{name = ?M} = Range, X) ->
  'clojerl.Cons':?CONSTRUCTOR(X, Range).

empty(_) -> [].

equiv( #?TYPE{name = ?M, data = X}
     , #?TYPE{name = ?M, data = Y}
     ) ->
  clj_core:equiv(X, Y);
equiv(#?TYPE{name = ?M} = X, Y) ->
  case clj_core:'sequential?'(Y) of
    true  -> clj_core:equiv(to_list(X), Y);
    false -> false
  end.

hash(#?TYPE{name = ?M} = X) ->
  clj_murmur3:ordered(to_list(X)).

meta(#?TYPE{name = ?M, info = Info}) ->
  maps:get(meta, Info, ?NIL).

with_meta(#?TYPE{name = ?M, info = Info} = Range, Metadata) ->
  Range#?TYPE{info = Info#{meta => Metadata}}.

first(#?TYPE{name = ?M, data = {Start, _, _}}) -> Start.

next(#?TYPE{name = ?M, data = {Start, End, Step}}) when
    Step >= 0, Start + Step > End;
    Step < 1, Start + Step < End ->
  ?NIL;
next(#?TYPE{name = ?M, data = {Start, End, Step}}) ->
  ?CONSTRUCTOR(Start + Step, End, Step).

more(#?TYPE{name = ?M, data = {Start, End, Step}}) when
    Step >= 0, Start + Step > End;
    Step < 1, Start + Step < End ->
  [];
more(#?TYPE{name = ?M, data = {Start, End, Step}}) ->
  ?CONSTRUCTOR(Start + Step, End, Step).

'_'(_) -> ?NIL.

seq(#?TYPE{name = ?M, data = {Start, Start, _}}) -> ?NIL;
seq(#?TYPE{name = ?M} = Seq) -> Seq.

to_list(#?TYPE{name = ?M, data = {Start, End, Step}}) ->
  lists:seq(Start, End, Step).

str(#?TYPE{name = ?M} = Range) ->
  ItemsStrs = lists:map(fun clj_core:str/1, to_list(Range)),
  Strs = 'clojerl.String':join(ItemsStrs, <<" ">>),
  <<"(", Strs/binary, ")">>.