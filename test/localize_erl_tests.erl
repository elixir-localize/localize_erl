-module(localize_erl_tests).
-include_lib("eunit/include/eunit.hrl").

all_test_() ->
    {setup,
     fun() -> application:ensure_all_started(localize) end,
     fun(_) -> ok end,
     [{"number", fun number/0},
      {"currency", fun currency/0},
      {"percent", fun percent/0},
      {"date", fun date_case/0},
      {"time", fun time_case/0},
      {"datetime", fun datetime/0},
      {"relative", fun relative/0},
      {"unit", fun unit/0},
      {"list", fun list/0},
      {"message", fun message/0},
      {"territory", fun territory/0},
      {"language", fun language/0},
      {"collation", fun collation/0},
      {"errors", fun errors/0}]}.

number() ->
    ?assertEqual({ok, <<"1,234.5">>}, localize_number:format(1234.5)),
    ?assertEqual({ok, <<"$1,234.56">>},
                 localize_number:format(1234.56, #{currency => <<"usd">>})).

currency() ->
    ?assertEqual({ok, <<"$1,234.56">>}, localize_currency:format(1234.56, <<"USD">>)),
    %% atom code, lower case, is upcased
    ?assertEqual({ok, <<"$1,234.56">>}, localize_currency:format(1234.56, usd)).

percent() ->
    ?assertEqual({ok, <<"56%">>}, localize_number:format(0.56, #{format => percent})).

date_case() ->
    ?assertEqual({ok, <<"Jul 10, 2025">>}, localize_date:format({2025, 7, 10})),
    ?assertEqual({ok, <<"Jul 10, 2025">>}, localize_date:format(<<"2025-07-10">>)),
    ?assertEqual({ok, <<"July 10, 2025">>},
                 localize_date:format({2025, 7, 10}, #{format => long})).

time_case() ->
    ?assertMatch({ok, _}, localize_time:format({14, 30, 0})).

datetime() ->
    ?assertMatch({ok, _}, localize_datetime:format(<<"2025-07-10T14:30:00Z">>)),
    ?assertMatch({ok, _}, localize_datetime:format({{2025, 7, 10}, {14, 30, 0}})).

relative() ->
    ?assertEqual({ok, <<"3 days ago">>}, localize_relative:format(-3, day)).

unit() ->
    ?assertEqual({ok, <<"42 km">>},
                 localize_unit:format(42, <<"kilometer">>, #{format => short})).

list() ->
    ?assertEqual({ok, <<"apple, banana, and cherry">>},
                 localize_list:format([<<"apple">>, <<"banana">>, <<"cherry">>])).

message() ->
    Mf2 = <<".input {$count :integer}\n.match $count\n"
            " one {{{$count} item}}\n * {{{$count} items}}">>,
    ?assertEqual({ok, <<"1 item">>}, localize_message:format(Mf2, #{count => 1})),
    ?assertEqual({ok, <<"5 items">>}, localize_message:format(Mf2, #{count => 5})).

territory() ->
    ?assertEqual({ok, <<"Australia">>}, localize_territory:name(<<"AU">>)),
    ?assertEqual({ok, <<"Australia">>}, localize_territory:name('AU')).

language() ->
    ?assertEqual({ok, <<"German">>}, localize_language:name(<<"de">>)),
    ?assertEqual({ok, <<"German">>}, localize_language:name(de)).

%% The manual-supervision path documented in the guide relies on
%% Localize.Supervisor exposing a supervisor child spec.
supervisor_child_spec_test() ->
    Spec = 'Elixir.Localize.Supervisor':child_spec([]),
    ?assertMatch(#{type := supervisor,
                   start := {'Elixir.Localize.Supervisor', start_link, [[]]}},
                 Spec).

collation() ->
    ?assertEqual(lt, localize_collation:compare(<<"apple">>, <<"banana">>)),
    ?assertEqual(gt, localize_collation:compare(<<"banana">>, <<"apple">>)),
    ?assertEqual(eq, localize_collation:compare(<<"a">>, <<"a">>)),
    ?assertEqual([<<"apple">>, <<"banana">>, <<"cherry">>],
                 localize_collation:sort([<<"banana">>, <<"apple">>, <<"cherry">>])),
    ?assertEqual([<<"cafe">>, <<"Cafe">>, <<"café"/utf8>>],
                 localize_collation:sort([<<"café"/utf8>>, <<"cafe">>, <<"Cafe">>])),
    ?assert(localize_collation:sort_key(<<"a">>) < localize_collation:sort_key(<<"b">>)).

errors() ->
    ?assertMatch({error, {invalid_locale, _}},
                 localize_number:format(1, #{locale => <<"xx-nope">>})),
    ?assertMatch({error, {invalid_date, _}}, localize_date:format(<<"not-a-date">>)),
    %% error terms carry a human-readable binary message
    {error, {invalid_locale, Message}} = localize_number:format(1, #{locale => <<"xx-nope">>}),
    ?assert(is_binary(Message)).
