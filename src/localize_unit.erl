-module(localize_unit).
-moduledoc """
Locale-aware units of measure ("42 km", "3 hours").
""".

-export([format/2, format/3]).

-doc """
Format a value in a named unit for the default locale.

## Examples

```erlang
{ok, <<"42 kilometers">>} = localize_unit:format(42, <<"kilometer">>).
```
""".
-spec format(number(), binary() | atom()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Value, Unit) ->
    format(Value, Unit, #{}).

-doc """
Format a value in a named unit with options, e.g. `#{format => short}`.

## Examples

```erlang
{ok, <<"42 km">>} = localize_unit:format(42, <<"kilometer">>, #{format => short}).
```
""".
-spec format(number(), binary() | atom(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Value, Unit, Options) ->
    case 'Elixir.Localize.Unit':new(Value, localize_util:to_binary(Unit)) of
        {ok, Measurement} ->
            localize_util:wrap(
              'Elixir.Localize.Unit':to_string(Measurement, localize_util:options(Options)));
        {error, _Reason} = Error ->
            localize_util:wrap(Error)
    end.
