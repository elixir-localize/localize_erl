-module(localize_list).
-moduledoc """
Locale-aware list formatting ("a, b, and c").
""".

-export([format/1, format/2]).

-doc """
Format a list of binaries as a locale-aware conjunction.

## Examples

```erlang
{ok, <<"apple, banana, and cherry">>} =
    localize_list:format([<<"apple">>, <<"banana">>, <<"cherry">>]).
```
""".
-spec format([binary()]) -> {ok, binary()} | {error, localize_util:error_reason()}.
format(Items) ->
    format(Items, #{}).

-doc """
Format a list with options, e.g. `#{locale => de}`.
""".
-spec format([binary()], localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Items, Options) ->
    localize_util:wrap('Elixir.Localize.List':to_string(Items, localize_util:options(Options))).
