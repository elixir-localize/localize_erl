# localize_erl

Idiomatic Erlang bindings for locale-aware formatting, backed by [Localize](https://hexdocs.pm/localize).

`localize_erl` gives Erlang locale-aware number, currency, date, time, unit, list and MessageFormat 2 formatting through small per-concern modules. It speaks Erlang: binaries in and out, maps for options, Erlang date/time tuples, and `{ok, Binary} | {error, {Tag, Message}}` returns.

Localize is a BEAM library, so no bridge is involved — each function is a direct call. This library exists to make those calls idiomatic: it shapes arguments the way an Erlang programmer expects and translates Localize's Elixir exceptions into ordinary Erlang error terms.

## Installation

Localize is an Elixir package, so it is pulled through [`rebar_mix`](https://github.com/Supersonido/rebar_mix):

```erlang
{plugins, [rebar_mix]}.

{provider_hooks,
 [{post, [{compile, {mix, consolidate_protocols}}]}]}.

{deps,
 [{localize_erl, "0.1.0"}]}.
```

## Usage

```erlang
{ok, <<"1,234.5">>}    = localize_number:format(1234.5).
{ok, <<"$1,234.56">>}  = localize_number:format(1234.56, #{currency => <<"USD">>}).
{ok, <<"56%">>}        = localize_number:format(0.56, #{format => percent}).
{ok, <<"1.234,56 €"/utf8>>} =
    localize_currency:format(1234.56, <<"EUR">>, #{locale => de}).

{ok, <<"July 10, 2025">>} = localize_date:format({2025, 7, 10}, #{format => long}).
{ok, <<"Jul 10, 2025">>}  = localize_date:format(<<"2025-07-10">>).
{ok, <<"3 days ago">>}    = localize_relative:format(-3, day).

{ok, <<"42 km">>} = localize_unit:format(42, <<"kilometer">>, #{format => short}).
{ok, <<"apple, banana, and cherry">>} =
    localize_list:format([<<"apple">>, <<"banana">>, <<"cherry">>]).

{ok, <<"Australia">>} = localize_territory:name(<<"AU">>).
{ok, <<"German">>}    = localize_language:name(de).

[<<"cafe">>, <<"Cafe">>, <<"café"/utf8>>] =
    localize_collation:sort([<<"café"/utf8>>, <<"cafe">>, <<"Cafe">>]).
lt = localize_collation:compare(<<"apple">>, <<"banana">>).
```

`localize_collation` returns its values directly — a sorted list, a `lt | eq | gt`
comparison, a sort-key binary — rather than `{ok, _}`, matching the idiom of
`lists:sort/1` and comparator functions.

### Modules

| Module | Function | Formats |
|---|---|---|
| `localize_number` | `format/1,2` | numbers, percentages, currency (via options) |
| `localize_currency` | `format/2,3` | currency amounts |
| `localize_date` | `format/1,2` | dates |
| `localize_time` | `format/1,2` | times |
| `localize_datetime` | `format/1,2` | datetimes |
| `localize_relative` | `format/2,3` | relative time |
| `localize_unit` | `format/2,3` | units of measure |
| `localize_list` | `format/1,2` | conjunction lists |
| `localize_message` | `format/1,2` | MessageFormat 2 (plurals) |
| `localize_territory` | `name/1,2` | territory display names |
| `localize_language` | `name/1,2` | language display names |
| `localize_collation` | `compare/2,3`, `sort/1,2`, `sort_key/1,2` | locale-aware collation |

### Conventions

* **Returns** are `{ok, Binary}` or `{error, {Tag, Message}}`, where `Tag` is an atom (`invalid_locale`, `invalid_date`, `unknown_currency`, …) and `Message` is a human-readable binary. Assert with `{ok, B} = ...` where you expect success.

* **Strings** are binaries. Options are a map with atom keys mirroring Localize's options: `#{locale => de, format => percent, currency => <<"USD">>, fractional_digits => 0}`.

* **Dates and times** accept an Erlang tuple (`{2025, 7, 10}`, `{14, 30, 0}`, `{{2025, 7, 10}, {14, 30, 0}}`) or an ISO 8601 binary.

## Locale data

Only the `en` locale ships with Localize. Install the locales you serve once, at build time, from a checkout of Localize:

```sh
mix localize.download_locales de fr ja
```

A call for a locale that has not been installed returns a value formatted with the root locale rather than an error.

## Development

```sh
rebar3 compile
rebar3 eunit
rebar3 dialyzer
rebar3 ex_doc
```

## License

Apache-2.0. See [LICENSE.md](LICENSE.md).
