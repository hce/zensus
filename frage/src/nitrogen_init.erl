-module(nitrogen_init).
-export ([init/0]).
	
%% Called during application startup.
%% Put other initialization code here.
init() ->
    application:start(nprocreg),
    application:start(nitrogen_mochiweb),


    spawn(fun() ->
		  pgsql_pool:start_link(zensus, 4,
					[{host, "127.0.0.1"},
					 {port, 5432},
					 {username, "zensus"},
					 {password, "oocee6Iekahx8r"},
					 {database, "zensus"},
					 {schema, "public"}]),
		  receive after infinity -> ok end
	  end).
   
