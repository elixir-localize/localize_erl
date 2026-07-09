-module(localize_currency).
-moduledoc """
Locale-aware currency formatting.

A thin wrapper over `localize_number` that sets the currency, so the amount is
rendered with the correct symbol, grouping and placement for the locale.
""".

-export([format/2, format/3]).

-doc """
Format an amount in the given currency for the default locale.

## Examples

```erlang
{ok, <<"$1,234.56">>} = localize_currency:format(1234.56, <<"USD">>).
```
""".
-spec format(number(), binary() | atom()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Amount, Code) ->
    format(Amount, Code, #{}).

-doc """
Format an amount in the given currency with options, e.g. `#{locale => de}`.

## Examples

```erlang
{ok, <<"1.234,56 €"/utf8>>} =
    localize_currency:format(1234.56, <<"EUR">>, #{locale => de}).
```
""".
-spec format(number(), binary() | atom(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Amount, Code, Options) when is_map(Options) ->
    localize_number:format(Amount, Options#{currency => Code});
format(Amount, Code, Options) when is_list(Options) ->
    localize_number:format(Amount, [{currency, Code} | Options]).
