# Changelog

## 0.2.0

Requires Localize 1.0. The previous requirement of `0.48.0` excluded it.

## 0.1.0

Initial release. Per-concern modules — `localize_number`, `localize_currency`, `localize_date`, `localize_time`, `localize_datetime`, `localize_relative`, `localize_unit`, `localize_list`, `localize_message`, `localize_territory` and `localize_language` — wrap Localize for locale-aware formatting. Every function takes binaries, atoms and Erlang date/time tuples with a map of options, and returns `{ok, Binary}` or `{error, {Tag, Message}}`. `localize_collation` adds locale-aware `compare/2,3`, `sort/1,2` and `sort_key/1,2`, which return their values directly in the manner of `lists:sort/1`.
