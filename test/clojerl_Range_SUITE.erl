-module(clojerl_Range_SUITE).

-include("clojerl.hrl").

-export([all/0, init_per_suite/1]).

-export([ new/1
        , count/1
        , str/1
        , is_sequential/1
        , hash/1
        , seq/1
        , equiv/1
        , cons/1
        , complete_coverage/1
        ]).

-type config() :: list().
-type result() :: {comments, string()}.

-spec all() -> [atom()].
all() ->
  ExcludedFuns = [init_per_suite, end_per_suite, all, module_info],
  Exports = ?MODULE:module_info(exports),
  [F || {F, 1} <- Exports, not lists:member(F, ExcludedFuns)].

-spec init_per_suite(config()) -> config().
init_per_suite(Config) ->
  application:ensure_all_started(clojerl),
  Config.

%%------------------------------------------------------------------------------
%% Test Cases
%%------------------------------------------------------------------------------

-spec new(config()) -> result().
new(_Config) ->
  Range = 'clojerl.Range':?CONSTRUCTOR(1, 3, 1),
  [1, 2, 3] = clj_core:to_list(Range),

  [] = 'clojerl.Range':?CONSTRUCTOR(2, 1, 1),

  {comments, ""}.

-spec count(config()) -> result().
count(_Config) ->
  Range = 'clojerl.Range':?CONSTRUCTOR(1, 10, 1),
  10 = clj_core:count(Range),

  Range2 = 'clojerl.Range':?CONSTRUCTOR(1, 10, 2),
  5 = clj_core:count(Range2),

  Range3 = 'clojerl.Range':?CONSTRUCTOR(10, 1, -1),
  10 = clj_core:count(Range3),

  Range4 = 'clojerl.Range':?CONSTRUCTOR(10, 1, -2),
  5 = clj_core:count(Range4),

  {comments, ""}.

-spec str(config()) -> result().
str(_Config) ->
  Range = 'clojerl.Range':?CONSTRUCTOR(1, 5, 1),
  <<"(1 2 3 4 5)">> = clj_core:str(Range),

  Range2 = 'clojerl.Range':?CONSTRUCTOR(5, 1, 1),
  <<"()">> = clj_core:str(Range2),

  {comments, ""}.

-spec is_sequential(config()) -> result().
is_sequential(_Config) ->
  Range = 'clojerl.Range':?CONSTRUCTOR(1, 3, 1),
  true = clj_core:'sequential?'(Range),

  {comments, ""}.

-spec hash(config()) -> result().
hash(_Config) ->
  Range1 = 'clojerl.Range':?CONSTRUCTOR(1, 3, 1),
  Range2 = 'clojerl.Range':?CONSTRUCTOR(3, 1, -1),

  Hash1 = 'clojerl.IHash':hash(Range1),
  Hash2 = 'clojerl.IHash':hash(Range2),

  true = Hash1 =/= Hash2,

  {comments, ""}.

-spec seq(config()) -> result().
seq(_Config) ->
  Range1 = 'clojerl.Range':?CONSTRUCTOR(1, 3, 1),
  1 = clj_core:first(Range1),
  [2, 3] = clj_core:to_list(clj_core:next(Range1)),
  [2, 3] = clj_core:to_list(clj_core:rest(Range1)),

  Range2 = 'clojerl.Range':?CONSTRUCTOR(1, 1, 1),
  1 = clj_core:first(Range2),
  ?NIL = clj_core:next(Range2),
  [] = clj_core:to_list(clj_core:rest(Range2)),

  Range3 = 'clojerl.Range':?CONSTRUCTOR(2, 1, 1),
  ?NIL = clj_core:first(Range3),
  ?NIL = clj_core:next(Range3),
  [] = clj_core:rest(Range3),

  {comments, ""}.

-spec equiv(config()) -> result().
equiv(_Config) ->
  Range = 'clojerl.Range':?CONSTRUCTOR(1, 3, 1),

  ct:comment("Check that lists with the same elements are equivalent"),
  Range1 = clj_core:with_meta(Range, #{a => 1}),
  Range2 = clj_core:with_meta(Range, #{b => 2}),
  true   = clj_core:equiv(Range1, Range2),

  ct:comment("Check that lists with the same elements are not equivalent"),
  Range3 = clj_core:with_meta('clojerl.Range':?CONSTRUCTOR(1, 4, 1), #{c => 3}),
  false  = clj_core:equiv(Range1, Range3),

  ct:comment("A clojerl.List and an clojerl.erlang.List"),
  true  = clj_core:equiv(Range, [1, 2, 3]),
  false = clj_core:equiv(Range, [1, 2, 3, a]),

  ct:comment("A clojerl.List and something else"),
  false = clj_core:equiv(Range1, whatever),
  false = clj_core:equiv(Range1, #{}),

  {comments, ""}.

-spec cons(config()) -> result().
cons(_Config) ->
  OneRange = 'clojerl.Range':?CONSTRUCTOR(2, 1, -1),

  ct:comment("Conj an element to a range"),
  ThreeList = clj_core:conj(OneRange, 3),

  3    = clj_core:count(ThreeList),
  true = clj_core:equiv(ThreeList, [3, 2, 1]),

  ct:comment("Conj an element to a list with one element"),
  FourList = clj_core:conj(ThreeList, 4),

  4    = clj_core:count(FourList),
  true = clj_core:equiv(FourList, [4, 3, 2, 1]),

  {comments, ""}.

-spec complete_coverage(config()) -> result().
complete_coverage(_Config) ->
  ?NIL  = 'clojerl.Range':'_'(?NIL),

  Range = 'clojerl.Range':?CONSTRUCTOR(1, 10, 1),
  []    = clj_core:empty(Range),

  RangeMeta = clj_core:with_meta(Range, #{a => 1}),
  #{a := 1} = clj_core:meta(RangeMeta),

  Range2 = 'clojerl.Range':?CONSTRUCTOR(1, 1, 1),
  Range  = clj_core:seq(Range),
  ?NIL   = clj_core:seq(Range2),

  {comments, ""}.