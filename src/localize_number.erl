-module(localize_number).
-moduledoc """
Locale-aware number formatting.

Formats integers, floats and decimals for a locale, including grouping,
decimal separators, percentages and currency amounts.
""".

-export([format/1, format/2]).

-doc """
Format a number for the default locale.

## Examples

```erlang
{ok, <<"1,234.5">>} = localize_number:format(1234.5).
```
""".
-spec format(number()) -> {ok, binary()} | {error, localize_util:error_reason()}.
format(Number) ->
    format(Number, #{}).

-doc """
Format a number with options.

Options mirror Localize's number options, e.g. `#{locale => de}`,
`#{currency => <<"USD">>}`, `#{format => percent}`,
`#{fractional_digits => 0}`.

## Examples

```erlang
{ok, <<"$1,234.56">>} = localize_number:format(1234.56, #{currency => <<"USD">>}).
{ok, <<"56%">>}       = localize_number:format(0.56, #{format => percent}).
```
""".
-spec format(number(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Number, Options) ->
    localize_util:wrap('Elixir.Localize.Number':to_string(Number, localize_util:options(Options))).
