-module(localize_language).
-moduledoc """
Localized language display names.

A code may be an atom (`de`) or a binary (`<<"de">>`).
""".

-export([name/1, name/2]).

-doc """
Localized name of a language for the default locale.

## Examples

```erlang
{ok, <<"German">>} = localize_language:name(<<"de">>).
```
""".
-spec name(atom() | binary()) -> {ok, binary()} | {error, localize_util:error_reason()}.
name(Code) ->
    name(Code, #{}).

-doc """
Localized name of a language with options, e.g. `#{locale => fr}`.
""".
-spec name(atom() | binary(), localize_util:options()) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
name(Code, Options) ->
    localize_util:wrap(
      'Elixir.Localize.Language':display_name(
        localize_util:code(Code, lower), localize_util:options(Options))).
