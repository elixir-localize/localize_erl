-module(localize_message).
-moduledoc """
MessageFormat 2 formatting, including CLDR pluralisation.

The message is an MF2 binary; bindings are a map whose keys may be atoms or
binaries.
""".

-export([format/1, format/2]).

-doc """
Format an MF2 message with no bindings.
""".
-spec format(binary()) -> {ok, binary()} | {error, localize_util:error_reason()}.
format(Message) ->
    format(Message, #{}).

-doc """
Format an MF2 message with bindings.

## Examples

```erlang
Mf2 = <<".input {$count :integer}\n.match $count\n"
        " one {{{$count} item}}\n * {{{$count} items}}">>,
{ok, <<"3 items">>} = localize_message:format(Mf2, #{count => 3}).
```
""".
-spec format(binary(), map() | [{atom() | binary(), term()}]) ->
          {ok, binary()} | {error, localize_util:error_reason()}.
format(Message, Bindings) ->
    localize_util:wrap(
      'Elixir.Localize.Message':format(localize_util:to_binary(Message), bindings(Bindings))).

-spec bindings(map() | list()) -> map().
bindings(Bindings) when is_map(Bindings) ->
    maps:fold(fun(Key, Value, Acc) ->
                      maps:put(localize_util:to_binary(Key), Value, Acc)
              end, #{}, Bindings);
bindings(Bindings) when is_list(Bindings) ->
    bindings(maps:from_list(Bindings));
bindings(_Bindings) ->
    #{}.
