-module(localize_territory).
-moduledoc """
Localized territory (country/region) display names.

A code may be an atom (`'AU'`) or a binary (`<<"AU">>`).
""".

-export([name/1, name/2]).

-doc """
Localized name of a territory for the default locale.

## Examples

```erlang
{ok, <<"Australia">>} = localize_territory:name(<<"AU">>).
```
""".
-spec name(atom() | binary()) -> {ok, binary()} | {error, localize_util:error_reason()}.
name(Code) ->
    name(Code, #{}).

-doc """
Localized name of a territory with options, e.g. `#{locale => fr}`.
""".
-spec name(atom() | binary(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
name(Code, Options) ->
    localize_util:wrap(
      'Elixir.Localize.Territory':display_name(
        localize_util:code(Code, upper), localize_util:options(Options))).
