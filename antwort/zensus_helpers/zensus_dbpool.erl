-module(zensus_dbpool).

-export([start/0]).

-export([cache/1]).

start() ->
    spawn(fun() ->
		  pgsql_pool:start_link(zensus, 1,
					[{host, "127.0.0.1"},
					 {port, 5432},
					 {username, "zensus"},
					 {password, "oocee6Iekahx8r"},
					 {database, "zensus"},
					 {schema, "public"}]),
		  receive after infinity ->
				  ok end
	  end),
    P = spawn(?MODULE, cache, [dict:new()]),
    register(zensus_cache, P).

cache(Dict) ->
    receive
	{insert, Key, Value} ->
	    ?MODULE:cache(dict:store(Key, Value, Dict));
	{get, P, Key} ->
	    try dict:fetch(Key, Dict) of
		Value ->
		    P ! [Value]
	    catch _:_ ->
		    P ! []
	    end,
	    ?MODULE:cache(Dict);
	_Else ->
	    ?MODULE:cache(Dict)
    end.		

