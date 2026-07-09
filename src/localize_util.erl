%% @private
%% Shared helpers for the localize_* modules: option coercion, value coercion
%% and translation of Localize's Elixir exceptions into idiomatic Erlang error
%% terms.
-module(localize_util).
-moduledoc """
Shared types for the `localize_*` modules.

The functions here are internal; only the exported types (`t:options/0` and
`t:error_reason/0`) are part of the public API.
""".

-export([options/1, to_binary/1, wrap/1,
         parse_date/1, parse_time/1, parse_datetime/1,
         code/2]).

-export_type([options/0, error_reason/0]).

-type options() :: map() | [{atom(), term()}].
%% A `{Tag, Message}' pair: `Tag' names the error kind, `Message' is the
%% human-readable text from Localize.
-type error_reason() :: {atom(), binary() | term()}.

%% @doc Convert a user option map (or proplist) into the keyword list Localize
%% expects. Currency codes are upper-cased; other values pass through.
-doc false.
-spec options(options()) -> [{atom(), term()}].
options(Options) when is_map(Options) ->
    maps:fold(fun(Key, Value, Acc) -> [{Key, coerce(Key, Value)} | Acc] end, [], Options);
options(Options) when is_list(Options) ->
    [{Key, coerce(Key, Value)} || {Key, Value} <- Options];
options(_Options) ->
    [].

%% @doc Coerce a charlist, atom or binary to a binary.
-doc false.
-spec to_binary(binary() | atom() | string()) -> binary().
to_binary(Value) when is_binary(Value) -> Value;
to_binary(Value) when is_atom(Value) -> atom_to_binary(Value, utf8);
to_binary(Value) when is_list(Value) -> unicode:characters_to_binary(Value);
to_binary(Value) -> Value.

%% @doc Pass a Localize `{ok, _}' through unchanged, and translate a Localize
%% `{error, Exception}' into `{error, {Tag, Message}}'.
-doc false.
-spec wrap({ok, binary()} | {error, term()}) -> {ok, binary()} | {error, error_reason()}.
wrap({ok, _Binary} = Ok) -> Ok;
wrap({error, Reason}) -> {error, reason(Reason)}.

%% @doc Parse an Erlang date tuple `{Y, M, D}' or an ISO 8601 binary into an
%% Elixir `Date' struct.
-doc false.
-spec parse_date(calendar:date() | binary()) -> {ok, term()} | {error, error_reason()}.
parse_date({_Y, _M, _D} = Date) -> from_erl('Elixir.Date', Date, invalid_date);
parse_date(Binary) when is_binary(Binary) -> from_iso('Elixir.Date', Binary, invalid_date).

%% @doc Parse an Erlang time tuple `{H, M, S}' or an ISO 8601 binary into an
%% Elixir `Time' struct.
-doc false.
-spec parse_time(calendar:time() | binary()) -> {ok, term()} | {error, error_reason()}.
parse_time({_H, _M, _S} = Time) -> from_erl('Elixir.Time', Time, invalid_time);
parse_time(Binary) when is_binary(Binary) -> from_iso('Elixir.Time', Binary, invalid_time).

%% @doc Parse an Erlang datetime `{{Y,M,D},{H,M,S}}' or an ISO 8601 binary into
%% an Elixir datetime struct.
-doc false.
-spec parse_datetime(calendar:datetime() | binary()) -> {ok, term()} | {error, error_reason()}.
parse_datetime({{_, _, _}, {_, _, _}} = DateTime) ->
    from_erl('Elixir.NaiveDateTime', DateTime, invalid_datetime);
parse_datetime(Binary) when is_binary(Binary) ->
    case 'Elixir.DateTime':from_iso8601(Binary) of
        {ok, DateTime, _Offset} -> {ok, DateTime};
        {error, _Reason} -> from_iso('Elixir.NaiveDateTime', Binary, invalid_datetime)
    end.

-spec from_erl(module(), tuple(), atom()) -> {ok, term()} | {error, error_reason()}.
from_erl(Module, Erlang, Tag) ->
    case Module:from_erl(Erlang) of
        {ok, Struct} -> {ok, Struct};
        {error, Reason} -> {error, {Tag, Reason}}
    end.

-spec from_iso(module(), binary(), atom()) -> {ok, term()} | {error, error_reason()}.
from_iso(Module, Binary, Tag) ->
    case Module:from_iso8601(Binary) of
        {ok, Struct} -> {ok, Struct};
        {error, Reason} -> {error, {Tag, Reason}}
    end.

%% @doc Normalise a territory/language code to an atom for Localize's display
%% functions. An atom passes through; a binary is up/down-cased per `Case' and
%% resolved to an already-existing atom (so a bogus code can never grow the atom
%% table), falling back to the binary if no such atom exists.
-doc false.
-spec code(atom() | binary(), upper | lower) -> atom() | binary().
code(Code, _Case) when is_atom(Code) ->
    Code;
code(Code, Case) when is_binary(Code) ->
    Cased = case Case of
                upper -> string:uppercase(Code);
                lower -> string:lowercase(Code)
            end,
    try binary_to_existing_atom(Cased, utf8)
    catch error:badarg -> Cased
    end.

-spec coerce(atom(), term()) -> term().
coerce(currency, Value) -> string:uppercase(to_binary(Value));
coerce(_Key, Value) -> Value.

-spec reason(term()) -> error_reason().
reason(Exception) when is_map(Exception) ->
    Struct = maps:get('__struct__', Exception, undefined),
    {tag(Struct), message(Exception)};
reason(Other) ->
    {localize_error, Other}.

-spec message(map()) -> binary().
message(Exception) ->
    try 'Elixir.Exception':message(Exception)
    catch _Class:_Error -> <<"formatting failed">>
    end.

-spec tag(atom()) -> atom().
tag(Struct) ->
    maps:get(Struct, tags(), localize_error).

-spec tags() -> #{atom() => atom()}.
tags() ->
    #{'Elixir.Localize.InvalidLocaleError' => invalid_locale,
      'Elixir.Localize.UnknownLocaleError' => unknown_locale,
      'Elixir.Localize.InvalidValueError' => invalid_value,
      'Elixir.Localize.ParseError' => parse_error,
      'Elixir.Localize.UnknownCurrencyError' => unknown_currency,
      'Elixir.Localize.UnknownUnitError' => unknown_unit,
      'Elixir.Localize.UnknownFormatError' => unknown_format,
      'Elixir.Localize.UnknownTerritoryError' => unknown_territory,
      'Elixir.Localize.UnknownLanguageError' => unknown_language}.
