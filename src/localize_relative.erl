-module(localize_relative).
-moduledoc """
Locale-aware relative time formatting ("3 days ago", "in 2 hours").
""".

-export([format/2, format/3]).

-doc """
Format a relative time from a number and a unit.

The unit is one of `second`, `minute`, `hour`, `day`, `week`, `month`,
`quarter` or `year`.

## Examples

```erlang
{ok, <<"3 days ago">>} = localize_relative:format(-3, day).
```
""".
-spec format(number(), atom()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Number, Unit) ->
    format(Number, Unit, #{}).

-doc """
Format a relative time with options, e.g. `#{locale => de}`.
""".
-spec format(number(), atom(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Number, Unit, Options) ->
    Opts = [{unit, Unit} | localize_util:options(Options)],
    localize_util:wrap('Elixir.Localize.DateTime.Relative':to_string(Number, Opts)).
