-module(localize_date).
-moduledoc """
Locale-aware date formatting.

Accepts an Erlang date tuple (`{Year, Month, Day}`) or an ISO 8601 binary.
""".

-export([format/1, format/2]).

-doc """
Format a date for the default locale.

## Examples

```erlang
{ok, <<"Jul 10, 2025">>} = localize_date:format({2025, 7, 10}).
{ok, <<"Jul 10, 2025">>} = localize_date:format(<<"2025-07-10">>).
```
""".
-spec format(calendar:date() | binary()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Date) ->
    format(Date, #{}).

-doc """
Format a date with options, e.g. `#{locale => de, format => long}`.

## Examples

```erlang
{ok, <<"July 10, 2025">>} =
    localize_date:format({2025, 7, 10}, #{format => long}).
```
""".
-spec format(calendar:date() | binary(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Date, Options) ->
    case localize_util:parse_date(Date) of
        {ok, Struct} ->
            localize_util:wrap(
              'Elixir.Localize.Date':to_string(Struct, localize_util:options(Options)));
        {error, _Reason} = Error ->
            Error
    end.
