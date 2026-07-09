-module(localize_datetime).
-moduledoc """
Locale-aware datetime formatting.

Accepts an Erlang datetime tuple (`{{Y, M, D}, {H, Mi, S}}`) or an ISO 8601
binary. A zoned ISO string keeps its zone; a bare one is treated as naive.
""".

-export([format/1, format/2]).

-doc """
Format a datetime for the default locale.

## Examples

```erlang
{ok, _} = localize_datetime:format(<<"2025-07-10T14:30:00Z">>).
{ok, _} = localize_datetime:format({{2025, 7, 10}, {14, 30, 0}}).
```
""".
-spec format(calendar:datetime() | binary()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(DateTime) ->
    format(DateTime, #{}).

-doc """
Format a datetime with options, e.g. `#{locale => fr, format => long}`.
""".
-spec format(calendar:datetime() | binary(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(DateTime, Options) ->
    case localize_util:parse_datetime(DateTime) of
        {ok, Struct} ->
            localize_util:wrap(
              'Elixir.Localize.DateTime':to_string(Struct, localize_util:options(Options)));
        {error, _Reason} = Error ->
            Error
    end.
