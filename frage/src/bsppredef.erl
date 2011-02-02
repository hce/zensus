%% -*- mode: nitrogen -*-
-module (bsppredef).
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
     #h1 { text="generator.zensus11.de - Erläuterungen" },
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
     "Beispiel für eine gute und eine schlechte Formulierung anhand einer konkreten Frage.",
     #p{},
     "Die Frage lautet: 'wie ist Ihr Geschlecht? [ ] männlich [ ] weiblich'.",
     #p{},
     #label{text="Gute ausformulierte Antworten:"},
     "<strong>männlich:</strong> 'Ich muß bekennen, daß ich männlichen Geschlechts bin'<br /><strong>weiblich:</strong> "
     "'Ich muß konstatieren, daß mein Geschlecht mit an Sicherheit grenzender Wahrscheinlichkeit "
     "weiblich ist.'",
     #p{},
     #label{text="Suboptimale ausformulierte Antworten:"},
     #p{},
     "<strong>männlich:</strong> 'Es bereitet mir kein Vergnügen, Ihnen mitzuteilen, wie mein Geschlecht ist, aber so sei es, männlich, jetzt wissen Sie es.'<br /><strong>weiblich:</strong> "
     "'Wie ich schon schrieb, bereitet es mir kein Vergnügen, aber ich sag es Ihnen trotzdem: weiblich.'",
     #p{},
     "Das Problem an der zweiten Variante ist, daß in der zweiten Antwort bezug auf die erste genommen wird. Die "
     "erste Antwort erscheint aber nur bei männlichen Personen im Fließtext. Darüber hinaus wird die Frage in ",
     "der zweiten Variante nicht erwähnt. 'weiblich' kann sich auf alles mögliche beziehen. 'ich bin weiblich' "
     "dagegen präzisiert, worauf sich die Antwort bezieht.",
     #p{},
     #button { postback=gotomain, text="Alles klar >>" }
    ].

event(gotomain) ->
    wf:redirect("/").
