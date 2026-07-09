-module(localize_collation).
-moduledoc """
Locale-aware string collation: comparison, sorting and sort keys.

Unlike the `localize_*` formatting modules, these return their values directly —
a comparison, a sorted list, a sort key — which is the idiomatic shape for a
comparator and sorter (compare `lists:sort/1`). They operate on binaries and
take the same option map as the rest of the library; a bad locale option
raises.
""".

-export([compare/2, compare/3, sort/1, sort/2, sort_key/1, sort_key/2]).

-doc """
Compare two strings for the default locale, returning their collation order.

## Examples

```erlang
lt = localize_collation:compare(<<"apple">>, <<"banana">>).
eq = localize_collation:compare(<<"a">>, <<"a">>).
```
""".
-spec compare(binary(), binary()) -> lt | eq | gt.
compare(StringA, StringB) ->
    compare(StringA, StringB, #{}).

-doc """
Compare two strings with options, e.g. `#{locale => de}`.
""".
-spec compare(binary(), binary(), localize_util:options()) -> lt | eq | gt.
compare(StringA, StringB, Options) ->
    'Elixir.Localize.Collation':compare(StringA, StringB, localize_util:options(Options)).

-doc """
Sort a list of strings for the default locale.

## Examples

```erlang
[<<"cafe">>, <<"Cafe">>, <<"café"/utf8>>] =
    localize_collation:sort([<<"café"/utf8>>, <<"cafe">>, <<"Cafe">>]).
```
""".
-spec sort([binary()]) -> [binary()].
sort(Strings) ->
    sort(Strings, #{}).

-doc """
Sort a list of strings with options, e.g. `#{locale => de}`.
""".
-spec sort([binary()], localize_util:options()) -> [binary()].
sort(Strings, Options) ->
    'Elixir.Localize.Collation':sort(Strings, localize_util:options(Options)).

-doc """
Build a binary sort key for a string.

Sort keys can be compared directly with `<`, `>` and `==`, which is useful for
storing a precomputed ordering (e.g. an index column).

## Examples

```erlang
true = localize_collation:sort_key(<<"a">>) < localize_collation:sort_key(<<"b">>).
```
""".
-spec sort_key(binary()) -> binary().
sort_key(String) ->
    sort_key(String, #{}).

-doc """
Build a binary sort key with options, e.g. `#{locale => de}`.
""".
-spec sort_key(binary(), localize_util:options()) -> binary().
sort_key(String, Options) ->
    'Elixir.Localize.Collation':sort_key(String, localize_util:options(Options)).
