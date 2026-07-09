-module(localize_time).
-moduledoc """
Locale-aware time formatting.

Accepts an Erlang time tuple (`{Hour, Minute, Second}`) or an ISO 8601 binary.
""".

-export([format/1, format/2]).

-doc """
Format a time for the default locale.

## Examples

```erlang
{ok, _} = localize_time:format({14, 30, 0}).
```
""".
-spec format(calendar:time() | binary()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Time) ->
    format(Time, #{}).

-doc """
Format a time with options, e.g. `#{locale => de, format => short}`.
""".
-spec format(calendar:time() | binary(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Time, Options) ->
    case localize_util:parse_time(Time) of
        {ok, Struct} ->
            localize_util:wrap(
              'Elixir.Localize.Time':to_string(Struct, localize_util:options(Options)));
        {error, _Reason} = Error ->
            Error
    end.
