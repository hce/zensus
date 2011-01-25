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
     #h1 { text="fragebogen.qapla.eu - Impressum" },
     #flash{},
     #p{},
     "Schön, daß Sie sich für das Impressum interessieren. "
     "Diese Website wird gehostet von:",
     #label{text="Hans-Christian Esperer"},
     #label{text="Alicestraße 27"},
     #label{text="64372 Ober-Ramstadt"},
     #label{text="E-Mail-Adresse: hc@qapla.eu"},
     #label{text="Telefon: 04040180196801"},
     #p{}
    ].
