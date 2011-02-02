%% -*- mode: nitrogen -*-
-module (impressum).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Impressum".

body() ->
    #container_12 { body=[
			  #grid_8 { alpha=true, prefix=2, suffix=2, omega=true, body=inner_body() }
			 ]}.

inner_body() -> 
    [
     #h1 { text="generator.zensus11.de - Impressum" },
     #flash{},
     #p{},
     "Schön, daß Sie sich für das Impressum interessieren. "
     "Dies ist ein Angebot von <a href=\"http://zensus11.de/impressum/\">zensus11.de</a>",
     #p{}
    ].
