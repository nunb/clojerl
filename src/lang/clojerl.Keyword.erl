-module('clojerl.Keyword').

-behavior('clojerl.IFn').
-behavior('clojerl.IHash').
-behavior('clojerl.Named').
-behavior('clojerl.Stringable').
-behaviour('erlang.io.IWriter').
-behaviour('erlang.io.IReader').

-export([ new/1
        , new/2
        , find/1
        , find/2
        ]).

-export(['clojerl.IFn.invoke'/2]).
-export(['clojerl.IHash.hash'/1]).
-export([ 'erlang.io.IReader.read'/1
        , 'erlang.io.IReader.read'/2
        , 'erlang.io.IReader.read_line'/1
        , 'erlang.io.IReader.skip'/2
        , 'erlang.io.IReader.unread'/2
        ]).
-export([ 'erlang.io.IWriter.write'/2
        , 'erlang.io.IWriter.write'/3
        ]).
-export([ 'clojerl.Named.name'/1
        , 'clojerl.Named.namespace'/1
        ]).
-export(['clojerl.Stringable.str'/1]).

-type type() :: atom().

-spec new(binary()) -> type().
new(Name) ->
  binary_to_atom(Name, utf8).

-spec new(binary(), binary()) -> type().
new(Namespace, Name) ->
  binary_to_atom(<<Namespace/binary, "/", Name/binary>>, utf8).

-spec find(binary()) -> type().
find(Name) ->
  try
    binary_to_existing_atom(Name, utf8)
  catch
    _:_ -> undefined
  end.

-spec find(binary(), binary()) -> type().
find(Namespace, Name) ->
  try
    binary_to_existing_atom(<<Namespace/binary, "/", Name/binary>>, utf8)
  catch
    _:_ -> undefined
  end.

%%------------------------------------------------------------------------------
%% Protocols
%%------------------------------------------------------------------------------

%% clojerl.IFn

'clojerl.IFn.invoke'(Keyword, [Map]) ->
  clj_core:get(Map, Keyword);
'clojerl.IFn.invoke'(Keyword, [Map, NotFound]) ->
  clj_core:get(Map, Keyword, NotFound);
'clojerl.IFn.invoke'(_, Args) ->
  CountBin = integer_to_binary(length(Args)),
  throw(<<"Wrong number of args for keyword, got: ", CountBin/binary>>).

%% clojerl.IHash

'clojerl.IHash.hash'(Keyword) when is_atom(Keyword) ->
  erlang:phash2(Keyword).

%% clojerl.Named

'clojerl.Named.name'(Keyword) ->
  KeywordBin = atom_to_binary(Keyword, utf8),
  case binary:split(KeywordBin, <<"/">>) of
    [_] -> KeywordBin;
    [_, Name] -> Name
  end.

'clojerl.Named.namespace'(Keyword) ->
  KeywordBin = atom_to_binary(Keyword, utf8),
  case binary:split(KeywordBin, <<"/">>) of
    [_] -> undefined;
    [Namespace, _] -> Namespace
  end.

%% clojerl.Stringable

'clojerl.Stringable.str'(Keyword) ->
  KeywordBin = atom_to_binary(Keyword, utf8),
  <<":", KeywordBin/binary>>.

%% erlang.io.IReader

'erlang.io.IReader.read'(IO) ->
  'erlang.io.IReader.read'(IO, 1).

'erlang.io.IReader.read'(IO, Length)
  when IO =:= standard_io; IO =:= standard_error ->
  maybe_binary(io:get_chars(IO, "", Length));
'erlang.io.IReader.read'(Name, Length) ->
  case erlang:whereis(Name) of
    undefined ->
      error(<<"Invalid process name">>);
    _ ->
      maybe_binary(io:get_chars(Name, "", Length))
  end.

'erlang.io.IReader.read_line'(IO)
  when IO =:= standard_io; IO =:= standard_error ->
  maybe_binary(io:request(IO, {get_line, unicode, ""}));
'erlang.io.IReader.read_line'(Name) ->
  case erlang:whereis(Name) of
    undefined ->
      error(<<"Invalid process name">>);
    _ ->
      maybe_binary(io:request(Name, {get_line, unicode, ""}))
  end.

'erlang.io.IReader.skip'(_IO, _Length) ->
  error(<<"unsupported operation: skip">>).

'erlang.io.IReader.unread'(_IO, _Ch) ->
  TypeName = atom_to_binary(?MODULE, utf8),
  error(<<"Unsupported operation: unread for ", TypeName/binary>>).

-spec maybe_binary(eof | string()) -> eof | binary().
maybe_binary(eof) -> eof;
maybe_binary(List) when is_list(List) -> list_to_binary(List).

%% erlang.io.IWriter

'erlang.io.IWriter.write'(Name, Str) when is_atom(Name) ->
  'erlang.io.IWriter.write'(Name, Str, []).

'erlang.io.IWriter.write'(IO, Format, Values)
  when IO =:= standard_io; IO =:= standard_error ->
  ok = io:fwrite(IO, Format, clj_core:seq_to_list(Values)),
  IO;
'erlang.io.IWriter.write'(Name, Str, Values) when is_atom(Name) ->
  case erlang:whereis(Name) of
    undefined ->
      error(<<"Invalid process name">>);
    _ ->
      io:fwrite(Name, Str, clj_core:seq_to_list(Values))
  end.
