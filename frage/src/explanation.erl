%% -*- mode: nitrogen -*-
-module (explanation).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Erläuterungen".

body() ->
    #container_12 { body=[
			  #grid_8 { alpha=true, prefix=2, suffix=2, omega=true, body=inner_body() }
			 ]}.

inner_body() -> 
    wf:comet(fun() ->
		     wf:replace(pnlExplanation,
				#panel { id = pnlExplanation, body=explanations() })
	     end),
				
    [
     #h1 { text="fragebogen.qapla.eu - Erläuterungen" },
     #flash{},
     #p{},
     #panel { style="float: right",
	      body=[
		    #link { text="Impressum", url="/impressum" }
		   ]
	     },

     #panel { id=pnlExplanation, body="Lade Erläuterungen..." }
    ].


explanations() ->
    [
     "Die Idee ist, einen Fließtext zu generieren. Alle Fragen des Zensus 2011 "
     "sollen in diesem Fließtext beantwortet werden. Dabei ist es wichtig, "
     "daß für jede Antwort so viele Formulierungen wie möglich existieren.",
     #p{},
     "Hier können Sie helfen: wählen Sie sich eine Frage aus, und formulieren Sie "
     "zu dieser Frage eine neue Antwortvariante. Es gibt zwei Typen von Fragen: "
     "<b>Ankreuzfragen</b> und <b>Textfragen</b>.",
     #p{},
     "Ankreuzfragen sind Fragen, bei denen eine oder mehrere vorgegebene Antworten "
     "angekreuzt werden können. Zum Beispiel wird nach dem Geschlecht gefragt; hier "
     "kann man männlich oder weiblich ankreuzen. Die Ausformulierte Antwort könnte "
     "lauten 'ich bin männlichen Geschlechts' beziehungsweise 'ich bin weiblichen Geschlechts'. "
     "Eine weitere Alternative sind die Formulierungen 'ich habe ein X- und ein Y-Chromosom' und "
     "'ich habe zwei X-Chromosomen'.",
     #p{},
     "Textfragen sind Fragen, bei denen keine vorgegebenen Auswahlmöglichkeiten existieren. "
     "Ein Beispiel ist die Frage nach dem Geburtsdatum. Hier müssen Tag, Monat sowie Jahr an"
     "gegeben werden. Die Ausformulierte Variante könnte zum Beispiel lauten: "
     "Wir schreiben das Jahr 1984 - der Monat Nummer 1 war angebrochen und gerade 2 Tag/e alt, da ward ich geboren, jawoll!",
     #p{},
     #button { postback=gotomain, text="Neue Formulierung hinzufügen >>" }
    ].

event(gotomain) ->
    wf:redirect("/").
