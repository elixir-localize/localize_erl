# Using localize_erl

`localize_erl` is a set of small, per-concern modules that format values for a locale, backed by [Localize](https://hexdocs.pm/localize). This guide covers supervision, the conventions, the modules, and where the edges and opportunities are.

## Supervision

Localize runs a small supervision tree at runtime — a data loader, a locale loader (which owns the locale-validation ETS table), a cache sweeper, a format cache, and the collation table. `localize_erl` itself has no processes of its own; it is a pure library. Crucially, it does **not** list `localize` in its `.app` `applications`, so it never forces Localize's tree to auto-start behind your back — you decide how that tree is run.

### Auto-start

The simplest option is to run `localize` as an ordinary OTP application. List it in your release and OTP brings its tree up at boot, before your own app:

```erlang
%% rebar.config
{relx, [{release, {my_app, "0.1.0"},
         [kernel, stdlib, localize, my_app]}]}.
```

Nothing else is needed; the `localize_*` functions work as soon as your app is up.

### Own the tree

If you would rather Localize's processes live under your own supervisor — to control start ordering, or simply because you keep third-party trees under your own roots — mount `Localize.Supervisor` as a child. It exposes a standard supervisor child spec, so it drops straight into your `init/1`:

```erlang
%% my_app_sup.erl
init([]) ->
    SupFlags = #{strategy => one_for_one},
    Children =
        [#{id => localize,
           start => {'Elixir.Localize.Supervisor', start_link, [[]]},
           type => supervisor}
         %% | your own children — after Localize if they format at startup
        ],
    {ok, {SupFlags, Children}}.
```

To keep OTP from *also* starting Localize's tree, include the application rather than starting it. Listing it under `included_applications` loads `localize` with your app but leaves its `start/2` to you — which is exactly what mounting `Localize.Supervisor` above does:

```erlang
%% my_app.app.src
{included_applications, [localize]},
```

Now there is exactly one Localize tree, and it is a child of yours.

### Ordering and one-time setup

`Localize.Supervisor` must start **before** any of your processes that format at startup (importers, first-tick workers). It can start **after** anything Localize does not depend on — repos, listeners, registries — since Localize reads its CLDR data from disk and needs no consumer-side process.

Starting the supervisor also runs Localize's idempotent one-time setup (interning CLDR atoms, resolving `supported_locales`). For the full rationale see Localize's own [supervision guide](https://hexdocs.pm/localize/supervision.html).

## Conventions

Every fallible function returns `{ok, Binary}` or `{error, {Tag, Message}}`. This is the standard Erlang idiom for operations that can fail on runtime data — here, an unknown locale or an unparseable date. `Tag` is an atom you can match on; `Message` is the human-readable text from Localize:

```erlang
case localize_number:format(Amount, #{locale => Locale}) of
    {ok, Text}                    -> Text;
    {error, {invalid_locale, _}}  -> localize_number:format(Amount)
end.
```

Where you expect success, assert it:

```erlang
{ok, Price} = localize_currency:format(Amount, <<"EUR">>, #{locale => de}).
```

Strings are binaries. Options are a map whose atom keys mirror Localize's options.

## Setting the locale once

Options take a `locale`, but the locale is also per-process. Set it once and option-less calls inherit it:

```erlang
'Elixir.Localize':put_locale(de),
{ok, <<"1.234,5">>} = localize_number:format(1234.5).
```

An explicit `#{locale => ...}` always overrides the process locale.

## Numbers, currency and percentages

```erlang
{ok, <<"1,234.5">>}   = localize_number:format(1234.5),
{ok, <<"$1,234.56">>} = localize_number:format(1234.56, #{currency => <<"USD">>}),
{ok, <<"56%">>}       = localize_number:format(0.56, #{format => percent}),
{ok, <<"$1,235">>}    = localize_number:format(1234.56, #{currency => <<"USD">>,
                                                          fractional_digits => 0}).
```

`localize_currency:format/2,3` is the same thing with the currency as a positional argument; a lower-case or atom code is upper-cased for you.

## Dates and times

Pass an Erlang tuple or an ISO 8601 binary:

```erlang
{ok, <<"Jul 10, 2025">>}  = localize_date:format({2025, 7, 10}),
{ok, <<"July 10, 2025">>} = localize_date:format(<<"2025-07-10">>, #{format => long}),
{ok, _}                   = localize_time:format({14, 30, 0}),
{ok, _}                   = localize_datetime:format(<<"2025-07-10T14:30:00Z">>),
{ok, <<"3 days ago">>}    = localize_relative:format(-3, day).
```

A malformed input is an error, not a silent fallback:

```erlang
{error, {invalid_date, _}} = localize_date:format(<<"not-a-date">>).
```

## Lists, units and messages

```erlang
{ok, <<"apple, banana, and cherry">>} =
    localize_list:format([<<"apple">>, <<"banana">>, <<"cherry">>]),

{ok, <<"42 km">>} = localize_unit:format(42, <<"kilometer">>, #{format => short}),

Mf2 = <<".input {$count :integer}\n.match $count\n"
        " one {{{$count} item}}\n * {{{$count} items}}">>,
{ok, <<"3 items">>} = localize_message:format(Mf2, #{count => 3}).
```

`localize_message` applies CLDR plural rules — the thing string interpolation cannot do. Binding keys may be atoms or binaries.

## Display names

```erlang
{ok, <<"Australia">>} = localize_territory:name(<<"AU">>),
{ok, <<"German">>}    = localize_language:name(de).
```

A code may be an atom or a binary; a binary resolves only to an already-existing atom, so a bogus code can never grow the atom table.

## Collation

Collation is the exception to the `{ok, _} | {error, _}` convention. `compare`, `sort` and `sort_key` are comparator/sorter operations, so — like `lists:sort/1` and a comparison fun — they return their values directly:

```erlang
lt = localize_collation:compare(<<"apple">>, <<"banana">>),

[<<"cafe">>, <<"Cafe">>, <<"café"/utf8>>] =
    localize_collation:sort([<<"café"/utf8>>, <<"cafe">>, <<"Cafe">>], #{locale => en}).
```

`sort_key/1,2` builds a binary that orders correctly under plain `<`/`>` comparison — useful for a precomputed index column:

```erlang
true = localize_collation:sort_key(<<"a">>) < localize_collation:sort_key(<<"b">>).
```

This is a deliberate, principled split rather than an inconsistency: fallible formatting returns tuples; pure comparison and sorting return values, exactly as Erlang's own stdlib does. A bad locale option raises.

## Limitations

* **Formatting only, one direction.** There is no parsing back, no collation, and no interval or duration formatting yet — see *Opportunities*.

* **Locale is process-scoped.** `Localize:put_locale/1` affects the whole process; pass an explicit `locale` when one call site needs a different one.

* **Depends on an Elixir package.** Localize is Elixir, so the project pulls it through `rebar_mix`, which needs Elixir on the build machine (only at build time).

* **Some errors degrade rather than fail.** An unknown territory code returns `{ok, <<"Unknown Region">>}` from Localize rather than an error — that is Localize's behaviour, surfaced as-is.

## Opportunities

* **More of Localize.** Natural next modules: `localize_interval`, `localize_duration`, locale-aware sorting (`localize_collation`), calendar names, and number *parsing* (binary → number).

* **A shared behaviour.** The modules share a call/coerce/wrap shape; a small behaviour could formalise it and make adding a module a two-line exercise.

* **Structured error detail.** Error terms are `{Tag, Message}` today; where a caller wants the offending value, the tag could carry it (e.g. `{unknown_currency, <<"XYZ">>}`).

Each new module is the same recipe: coerce the Erlang arguments, call the relevant Localize function, and wrap the result into the `{ok, _} | {error, _}` form.
