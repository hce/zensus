-module(zensus_dbpool).

-export([start/0]).

start() ->
    spawn(fun() ->
		  ets:new(zensus_cache, [set, public,
					 named_table]),
		  pgsql_pool:start_link(zensus, 1,
					[{host, "127.0.0.1"},
					 {port, 5432},
					 {username, "zensus"},
					 {password, "oocee6Iekahx8r"},
					 {database, "zensus"},
					 {schema, "public"}]),
		  receive after infinity ->
				  ok end
	  end).

