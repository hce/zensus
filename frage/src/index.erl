%% -*- mode: nitrogen -*-
-module (index).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Zensus Ausfüllung".

body() ->
    #container_12 { body=[
			  #grid_8 { alpha=true, prefix=2, suffix=2, omega=true, body=inner_body() }
			 ]}.

do_qstat(C) ->    
    {ok, _Cols, Rows1} = pgsql:squery(C, "SELECT qid FROM questions"),
    lists:foldl(
      fun({Qid}, D) ->
	      dict:store(Qid, try dict:fetch(Qid, D) of
				  Value ->
				      Value
			      catch _:_ ->
				      0 end + 1, D)
      end, dict:new(), Rows1).

do_qlist(C) ->
    Dict = do_qstat(C),
    Keys = dict:fetch_keys(Dict),
    {Minimum1, Count} = lists:foldl(
			  fun(Qid, {Current, Count}) ->
				  Qid_num = dict:fetch(Qid, Dict),
				  if Qid_num < Current ->
					  {Qid_num, Count + Qid_num};
				     true ->
					  {Current, Count + Qid_num}
				  end
			  end, {65536, 0}, Keys),
    Minimum = case length(Keys) of
		  45 -> Minimum1;
		  _Else -> 0
	      end,
    
    if
	Minimum =:= 0 ->
	    {lists:subtract([list_to_binary(integer_to_list(E)) ||
				E <- [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
				      21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
				      41, 42, 43, 44, 45, 46]], Keys), Count};
	true ->
	    {[Key || Key <- Keys,
		     dict:fetch(Key, Dict) =:= Minimum], Count}
    end.    

inner_body() -> 
    wf:comet(fun() ->
		     {ok, C} = pgsql_pool:get_connection(zensus),
		     {Qlist1, Count1} = do_qlist(C),
		     pgsql_pool:return_connection(zensus, C),

		     Qlist2 = [binary_to_list(Entry) || Entry <- Qlist1],
		     Qlist = string:join(Qlist2, ", "),
		     Count = integer_to_list(Count1),
		     %Qlist="tbi",
		     
		     wf:replace(pnlIntro,
				#panel { id=pnlIntro,
					 body=[
					       "
		Hallo und Vielen Dank für Ihr Interesse an unserem Projekt! Details zum
                Zensus 2011 finden Sie auf der Website
		   ",
					       #link { text="zensus11.de", url="http://zensus11.de" }, ". ",
					       "Bei Fragen: info@generator.zensus11.de",
					       #p{},
					       "
		Hinweis: Sie geben das Copyright an sämtlichen hier gemachten
		   Angaben auf (public domain). Sollten Sie damit nicht einverstanden sein, so machen
                   Sie bitte keine Angaben.",
					       #p{},
					       "For the record: es geht hier natürlich nicht darum, daß
persönliche Angaben gemacht werden. Die Fragen sollen nicht direkt beantwortet werden. Vielmehr sollen
abstrakte Formulierungen gesammelt werden, mit Hilfe derer ein Fragebogen als Fließtext beantwortet
werden kann. <a href='/explanation'>Beispiel</a>",
					       #p{},
"Wir haben bereits <strong>", Count, "</strong> eingegangene Formulierungen. ",
					       "Einige Fragen, die am dringensten Antworten brauchen: ", Qlist
					      ]
					} )
	     end),
    [
     #h1 { text="generator.zensus11.de - Neue Ausformulierung hinzufügen" },
     #flash{},
     #panel{
	     style="float: right",
	     body=[
		   #link {url="/explanation", text="Erläuterungen"},
		   " -- ",
		   #link {url="/impressum", text="Impressum"}
		  ]
	    },
     #p{},
     #panel { id=pnlQuestion },
     #p{},
     #panel{
	 id=pnlThanks,
	 style="display: none",
	 body=[
	       "
		Vielen, vielen Dank! Ihre Angaben werden unserer Datenbank
	       hinzugefügt.
",
		#p{},
#button { text="Noch eine Frage hinzufügen", postback=anotherone }
]
},
#panel{
	     id=pnlIntro,
	     body=[
		   "
		Hallo und Vielen Dank für Ihr Interesse an unserem Projekt!
		   ",
		#p{},
		   "
		Hinweis: Sie geben das Copyright an sämtlichen hier gemachten
		   Angaben auf (public domain). Sollten Sie damit nicht einverstanden sein, so machen
                   Sie bitte keine Angaben.
",#p{},
"For the record: es geht hier natürlich nicht darum, daß
persönliche Angaben gemacht werden. Die Fragen sollen nicht direkt beantwortet werden. Vielmehr sollen
abstrakte Formulierungen gesammelt werden, mit Hilfe derer ein Fragebogen als Fließtext beantwortet
werden kann. <a href='/explanation'>Beispiel</a>",
					       #p{}
	    ]
},
#panel{
	id=page1,
	body=page1()
       },
#panel{
	id=page2
       }
].

fragen() ->
    [
     #option { text="1. Vor- und Nachname", value="1" },
     #option { text="2. Adressangaben", value="2" },
     #option { text="3. Telefonnummer", value=3 },
     #option { text="4. Geschlecht", value="4" },
     #option { text="5. Geburtsdatum", value="5" },
     #option { text="6. Staatsangehörigkeit", value="6" },
     #option { text="7. Religionsgesellschaft", value="7" },
     #option { text="9. Familienstand", value="9" },
     #option { text="10. Lebenspartnerfrage", value="10" },
     #option { text="11. Personen im Haushalt", value="11" },
     #option { text="12. Bewohnen Sie eine weitere Wohnung in Deutschland?", value="12" },
     #option { text="13. Ist die hiesige Wohnung die vorwiegend benutzte Wohnung?", value="13" },
     #option { text="14. Zuzug nach 1955", value="14" },
     #option { text="15. Zuzug wann genau, falls", value="15" },
     #option { text="16. Zuzug von wo, falls", value="16" }, 
     #option { text="17. Mutter Zuzug nach 1955 ja/nein", value="17" }, 
     #option { text="18. Mutter Zuzug wann, falls", value="18" }, 
     #option { text="19. Mutter Zuzug von wo, falls", value="19" }, 
     #option { text="20. Vater Zuzug nach 1955 ja/nein", value="20" }, 
     #option { text="21. Vater Zuzug wann, falls", value="21" }, 
     #option { text="22. Vater Zuzug von wo, falls", value="22" }, 
     #option { text="23. Waren Sie in der Woche vom 9. bis 15. Mai 2011 Schüler/-in einer allgemeinbildenden Schule?", value="23" }, 
     #option { text="24. Um welche Schule handelte es sich dabei?", value="24" }, 
     #option { text="25. Welche Klasse besuchten Sie?", value="25" }, 
     #option { text="26. Haben Sie einen allgemeinbildenden Schulabschluss?", value="26" }, 
     #option { text="27. Welchen höchsten allgemeinbildenden Schulabschluss haben Sie?", value="27" }, 
     #option { text="28. Haben Sie einen beruflichen Ausbildungs- oder (Fach-)hochschulabschluss?", value="28" }, 
     #option { text="29. Welchen höchsten beruflichen Ausbildungs- oder (Fach-)Hochschulabschluss haben Sie?", value="29" }, 
     #option { text="30. Berufstätigkeit, Nebenjobs", value="30" }, 
     #option { text="31. Arbeit eine Stunde pro Woche oder mehr", value="31" }, 
     #option { text="32. Unbezahlte Arbeit in Familienbetrieb", value="32" }, 
     #option { text="33. Arbeit eine Stunde oder mehr vom 9. bis 15. Mai?", value="33" }, 
     #option { text="34. Falls 33. nein, warum?", value="34" }, 
     #option { text="35. Dauer der Unterbrechung der Tätigkeit", value="35" }, 
     #option { text="36. Fortzahlung des Einkommens", value="36" }, 
     #option { text="37. Als was sind Sie tätig?", value="37" }, 
     #option { text="38. Arbeitsort", value="38" }, 
     #option { text="39. PLZ und Ort des überwiegenden Arbeitsortes", value="39" }, 
     #option { text="40. Arbeitssuche die letze Woche?", value="40" }, 
     #option { text="41. Könnten Sie innerhalb der nächsten zwei Wochen eine bezahlte Tätigkeit aufnehmen?", value="41" }, 
     #option { text="42. Früher schonmal gegen Bezahlung gearbeitet?", value="42" }, 
     #option { text="43. Als was waren Sie zuletzt tätig?", value="43" }, 
     #option { text="44. Arbeitsstätte Branche/Wirtschaftszweig", value="44" }, 
     #option { text="45. Ausgeübter Beruf/Tätigkeit", value="45" }, 
     #option { text="46. Stichworte zur Tätigkeit", value="46" }
    ].

frage(N) ->
    frage(integer_to_list(N), fragen()).
frage(N, [#option{text=Text, value=N}|_R]) ->
    Text;
frage(N, [_|R]) ->
    frage(N, R);
frage(N, []) ->
    error_logger:error_msg("Error 1843: ~p", [N]).

fragedetails(1) ->
    {text, ["Vorname/-n", "Nachname"]};
fragedetails(2) ->
    {text, ["Straße", "Hausnummer", "PLZ", "Ort"]};
fragedetails(3) ->
    {text, ["Telefonnummer"]};
fragedetails(4) ->
    {predef, ["Männlich", "Weiblich"]};
fragedetails(5) ->
    {text, ["Tag", "Monat", "Jahr"]};
fragedetails(6) ->
    {predef, ["Deutsche Staatsangehörigkeit",
	      "Staatsangehörigkeit eines anderen EU-Staates",
	      "Staatsangehörigkeit eines Nicht-EU-Staates",
	      "Staatenlos",
	      "Ungeklärt"]};
fragedetails(7) ->
    {predef, ["Römisch-katholische Kirche",
	      "Evangelische Kirche",
	      "Evangelische Freikirchen",
	      "Orthodoxe Kirchen",
	      "Jüdische Gemeinden",
	      "Sonstige öffentlich-rechtliche Religionsgesellschaft",
	      "Keiner öffentlich-rechtlichen Religionsgesellschaft"]};
fragedetails(9) ->
    {predef, ["Ledig", "Verheiratet", "Geschieden", "Verwitwet",
	      "Eingetragene Lebenspartnerschaft (gleichgeschlechtlich)",
	      "Eingetragene Lebenspartnerschaft (gleichgeschlechtlich) aufgehoben",
	      "Eingetragener Lebenspartner / Eingetragene "
	      "Lebensparnerin (gleichgeschlechtlich) verstorben"]};
fragedetails(10) ->
    {predef, ["Ja", "Nein"]};
fragedetails(11) ->
    {text, ["Anzahl der Personen (Sie einbezogen)"]};
fragedetails(12) ->
    {predef, ["Ja", "Nein"]};
fragedetails(13) ->
    {predef, ["Ja", "Nein"]};
fragedetails(14) ->
    {predef, ["Ja", "Nein"]};
fragedetails(15) ->
    {text, ["In welchem Jahr war das?"]};
fragedetails(16) ->
    {text, ["Aus welchem Staat sind Sie zugezogen?"]};
fragedetails(17) ->
    {predef, ["Ja", "Nein"]};
fragedetails(18) ->
    {text, ["In welchem Jahr war das?"]};
fragedetails(19) ->
    {text, ["Aus welchem Staat ist Ihre Mutter zugezogen?"]};
fragedetails(20) ->
    {predef, ["Ja", "Nein"]};
fragedetails(21) ->
    {text, ["In welchem Jahr war das?"]};
fragedetails(22) ->
    {text, ["Aus welchem Staat ist Ihr Vater zugezogen?"]};
fragedetails(23) ->
    {predef, ["Ja", "Nein"]};
fragedetails(24) ->
    {predef, ["Grundschule", "Hauptschule", "Realschule",
	      "Gymnasium", "Gesamtschule", "Sonstige Schule"]};
fragedetails(25) ->
    {predef, ["Klasse 1 bis 4",
	      "Klasse 5 bis 9 oder 10",
	      "Klasse 11 bis 13 (gymnasiale Oberstufe)"]};
fragedetails(26) ->
    {predef, ["Ja", "Nein", "Noch nicht"]};
fragedetails(27) ->
    {predef, ["Abschluss nach höchstens 7 Jahren Schulbesuch "
	      "(insbesondere Abschluss im Ausland)",
	      "Haupt-/Volksschulabschluss",
	      "Realschulabschluss (Mittlere Reife), Abschluss der "
	      "Polytechnischen Oberschule oder gleichwertiger Abschluss",
	      "Fachhochschulreife",
	      "Allgemiene oder fachgebundene Hochschulreife (Abitur)"]};
fragedetails(28) ->
    {predef, ["Ja", "Nein", "Noch nicht"]};
fragedetails(29) ->
    {predef, ["Anlernausbildung oder berufliches Praktikum "
	      "von mindestens 12 Monaten",
	      "Berufsvorbereitungsjahr",
	      "Lehre, Berufsausblidung im dualen System",
	      "Vorbereitungsdienst für den mittleren Dienst "
	      "in der öffentlichen Verwaltung",
	      "Berufsqualifizierender Abschluss an einer "
	      "Berufsfachschule/Kollegschule, Abschluss einer "
	      "1-jährigen Schule des Gesundheitswesens",
	      "2- oder 3-jährige Schule des Gesundheitswesens "
	      "(z.B. Krankenpflege, PTA, MTA)",
	      "Fachschluabschluss (Meister/-in, Techniker/-in "
	      "oder gleichwertiger Abschluss)",
	      "Berufsakademie, Fachakademie",
	      "Abschluss einer Verwaltungsfachhochschule",
	      "Fachhochschulabschluß, auch Ingenieurschulabschluß",
	      "Abschluss einer Universität, wissenschaftlichen "
	      "Hochschule, Kunsthochschule",
	      "Promotion"]};
fragedetails(30) ->
    {predef, ["Ich bin erwerbs- bzw. berufs"
	      "tätig (inkl. Auszubildende, "
	      "Personen in Elternzeit oder "
	      "Altersteilzeit)",
	      "Ich bin Grundwehr-/Zivildienstleistender",
	      "Ich bin Schüler/-in",
	      "Ich bin Student/-in",
	      "Ich bin Rentner/-in, Pensionär/-in",
	      "Ich lebe von Einkünften aus Kapitalvermögen, "
	      "Vermietung oder Verpachtung.",
	      "Ich bin Hausfrau/-mann oder "
	      "versorge Kinder und/oder pflegebedürftige Personen.",
	      "Ich bin arbeitslos.",
	      "Keine der genannten Auswahlmöglichkeiten "
	      "(z.B. dauerhaft arbeitsunfähig)"]};
fragedetails(31) ->
    {predef, ["Ja", "Nein"]};
fragedetails(32) ->
    {predef, ["Ja", "Nein"]};
fragedetails(33) ->
    {predef, ["Ja", "Nein"]};
fragedetails(34) ->
    {predef, ["Unregelmäßige Arbeitszeiten",
	      "Urlaub/Sonderurlaub",
	      "Krankheit", "Elternzeit",
	      "Mutterschutz", "Altersteilzeit",
	      "Weiterbildungsmaßnahme",
	      "Sonstiger Grund"]};
fragedetails(35) ->
    {predef, ["Weniger als 3 Monate",
	      "3 Monate und mehr"]};
fragedetails(36) ->
    {predef, ["Ja", "Nein",
	      "Trifft nicht zu, da Selbstständige/-r "
	      "oder mithelfende/-r Familienangehörige/-r"]};
fragedetails(37) ->
    {predef, ["Angestellte/-r",
	      "Arbeiter/-in, Heimarbeiter/-in",
	      "Auszubildenre/-r",
	      "Selbstständige/-r ohne Beschäftigte (auch "
	      "Honorarkräfte, Personen mit Werkvertrag)",
	      "Selbstständige mit Beschäftigten",
	      "Mithelfende/-r Familienangehörige/-r "
	      "(unbezahlte Tätigkeit)",
	      "Beamter/Beamtin, Richter/-in, "
	      "Dienstordnungsangestellte/-r",
	      "Zeitsoldat/-in, Berufssoldat/-in",
	      "Grundwehr-/Zivildienstleistender",
	      "Nebenjobber/-in, 1-Euro-Jobber/-in"]};
fragedetails(38) ->
    {predef, ["...überwiegend in Ihrer Wohnung",
	      "...überwiegend nicht in Ihrer Wohnung"]};
fragedetails(39) ->
    {text, ["PLZ", "Ort"]};
fragedetails(40) ->
    {predef, ["Ja",
	      "Nein, ich habe bereits eine Tätigkeit gefunden",
	      "Nein, ich suche keine Arbeit."]};
fragedetails(41) ->
    {predef, ["Ja", "Nein"]};
fragedetails(42) ->
    {predef, ["Ja, zuletzt vor zehn oder weniger Jahren",
	      "Ja, zuletzt vor mehr als zehn Jahren",
	      "Nein"]};
fragedetails(43) ->
    {predef, ["Angestellte/-r",
	      "Arbeiter/-in, Heimarbeiter/-in",
	      "Auszubildende/-r",
	      "Selbstständige/-r ohne Beschäftigte (auch "
	      "Honorarkräfte, Personen mit Werkvertrag)",
	      "Selbstständige mit Beschäftigten",
              "Mithelfende/-r Familienangehörige/-r "
              "(unbezahlte Tätigkeit)",
              "Beamter/Beamtin, Richter/-in, "
              "Dienstordnungsangestellte/-r",
              "Zeitsoldat/-in, Berufssoldat/-in",
              "Grundwehr-/Zivildienstleistender",
              "Nebenjobber/-in, 1-Euro-Jobber/-in"]};
fragedetails(44) ->
    {predef, ["Land- und Forstwirtschaft, Fischerei",
	      "Bergbau und Gewinnung von Erdöl, Erdgas, Steinen und Erden",
	      "Verarbeitendes Gewerbe/Herstellung von Waren",
	      "Reparatur und Installation von Maschinen und Ausrüstungen",
	      "Energieversorgung",
	      "Wasserversorgung; Abwasser- und Abfallentsorgung und "
	      "Beseitigung von Umweltverschmutzungen",
	      "Groß- und Einzelhandel; Instandhaltung und Reparatur von Kraftfahrzeugen",
	      "Personen- und Güterverkehr; Lagerei (auch Post- und Kurierdienste)",
	      "Gastgewerbe/Beherbergung und Gastronomie",
	      "Information und Kommunikation",
	      "Banken/Finanz- und Versicherungsdienstleister",
	      "Grundstücks- und Wohnungswesen",
	      "Freiberufliche, wissenschaftliche und technische Dienstleistungen",
	      "Sonstige wirtschaftliche Dienstleistungen für Unternehmen und "
	      "Privatpersonen",
	      "Öffentliche Verwaltung, Gerichte, Öffentliche Sicherheit und "
	      "Ordnung, Verteidigung, Sozialversicherung",
	      "Erziehung und Unterricht (z.B. Hochschulen, Schulen, sonstige Schulen ",
	      "(auch Fahrschulen), Kindergärten)"
	      "Gesundheits- und Sozialwesen (z.B. Krankenhäuser, Arztpraxen, "
	      "Alten- und Pflegeheime)",
	      "Sonstige Überwiegend Personenbezogene Dienstleistungen; "
	      "allgemeine Reparaturen von Waren und Geräten "
	      "(z.B. Friseur- und Kosmetiksalon, Wäscherei, Solarium/Sauna/Bad, "
	      "Bestattung)",
	      "Kunst, Unterhaltung, Sport und Erholung ("
	      "z.B. Theater, Museen, schriftstellerische Tätigkeiten, "
	      "Sport- und Fitnesszentren",
	      "Gewerkschaften, Verbände, Parteien und sonstige "
	      "Interessenvertretungen, kirchliche und religiöse Vereinigungen",
	      "Konsulate, Botschaften, internationale und supranationale "
	      "Organisationen",
	      "Private Haushalte mit Beschäftigten"
	     ]};
fragedetails(45) ->
    {text, ["Bitte geben Sie an, welchen Beruf/welche bezahlte Tätigkeit Sie ausüben."]};
fragedetails(46) ->
    {text, ["Um die Einordnung Ihrer Tätigkeit zu erleichtern, geben Sie bitte zusätzliche "
	    "Erläuterungen in Stichworten an. Falls Sie überwiegend Führungsaufgaben "
	    "wahrnehmen, vermerken Sie dies bitte auch."]}.




page1() ->
    [
     #p{},
     #label { text="Ihr Name/Pseudonym/Nickname" },
     #textbox { id=txtName, text="" },
     "Absolut freiwillige Angabe; wird in der
         Danksagung erwähnt, sofern angegeben.
",
	#p{},
#label { text="Frage" },
#dropdown { id=lstQuestion, options=fragen() },
"
         Bitte wählen Sie die Frage aus, für die Sie eine neue
Antwortformulierung eintragen möchten.
",
	#p{},
#button {
	    id=btnQtype,
	    text="Weiter >>",
	    postback=qtype
	   }
].

wire_numcheck() ->
    wf:wire(btnNumFields, txtNumFields, #validate { validators=[
								#custom{
	    text="Ungültige Angabe.",
	    function=fun(_Tag, Value) ->
		try list_to_integer(Value) of
		    Value1 when Value1 > 0, Value1 =< 50 -> true;
		    _Else -> false
		catch
		    _:_ -> false
		end
	    end
	}
    ]}).

details_body(text) ->
    [
	#panel{
	    id=subquestions
	},
	#panel{
	    id=answertext,
	    body=[
		#label { text="Antworttext" },
		#textarea{
		    id=txtAnswer,
		    text="",
		    style="width: 512px; height: 200px"
		},
		#br{},
		"
		Formulieren Sie in dem großen Textfeld die Antwort
		auf die Frage aus. Alle Teilfragen sollen in einem großen
		Text gemeinschaftlich beantwortet werden. Sie können die Antwort
		auf jede Teilfrage durch Angabe von ~1s ersetzen, wobei die Zahl
		angibt, welche Teilfrage eingesetzt werden soll. In der ausformulierten
                Antwort muß <strong>erkennbar sein, welche Frage beantwortet wird</strong>.
                Denn die ursprünglichen Fragen werden im Antwortaufsatz nicht enthalten sein.
		",
		#p{},
		"
		Beispiel: Es ist nach PLZ(1) und Ort(2) gefragt. Die ausformulierte
		Antwort könnte also zum Beispiel lauten: 'Mein Wohnort, in dem ich lebe, dieser Lautet ~2s. Die
		zugehörige Postleitzahl, die diesem Ort zugeordnet wurde, lautet ~1s.'
		",
		#p{},
		#button { id=btnFertig, text="Weiter >>", postback=fin }
	    ]
	}
    ];
details_body(predef) ->
        [
	 "Bitte geben Sie für jede Auswahlmöglichkeit eine ausführliche Antwort in Form eines Fließtextes an. "
	 "Von einem Antworttext sollte kein Bezug auf einen anderen Antworttext genommen werden, "
	 "damit jeder Antworttext an beliebiger Stelle und in beliebigem Kontext genutzt werden kann. ",
	 "<br />",
	 "Im Antworttext muß <strong>unbedingt die Frage selbst erwähnt werden</strong>, da die "
	 "ursprüngliche Frage im Antwortaufsatz nicht enthalten sein wird.",
	 #link { text="Kurzes Beispiel", url="/bsppredef" },
	 #p{},
	 #panel{
            id=subquestions
        },
	 #panel{
		 id=answertext,
		 body=[
		       #button {
                    id=btnFertig,
                    text="Weiter >>",
                    postback=fin }
		      ]
        }
	].

subquestions(text, Count, [Question|R]) ->
    wf:state("txtQ" ++ integer_to_list(Count), Question),
    subquestions(text, Count-1, R) ++
    [
     #label { text="Teilfrage " ++ integer_to_list(Count) ++ ": " ++
	      Question, style="width: 512px" }
    ];
subquestions(predef, Count, [Question|R]) ->
    wf:state("txtQ" ++ integer_to_list(Count), Question),
    subquestions(predef, Count-1, R) ++
    [
%%	#label { text=io_lib:format("Ankreuzmöglichkeit ~p", [Count]) },
	#label { text="[ ] " ++ Question ++ ":", style="width: 512px" },
%%	#label { text="Antwort auf Frage, falls angekreuzt" },
	#textarea { id="txtA" ++ integer_to_list(Count),
		    text="", style="width: 512px; height: 80px" }
    ];
subquestions(_Type, 0, []) ->
    [].

wire_subvalidators(text, _Count) ->
    ok;
wire_subvalidators(predef, Count) when Count > 0 ->
    wf:wire(btnFertig, "txtA" ++ integer_to_list(Count), #validate { validators=[
	#is_required { text="Erforderliche Angabe." }
    ]}),
    wire_subvalidators(predef, Count-1);
wire_subvalidators(_Type, 0) ->
    ok.

check_referencing(Count, Value) when Count > 0 ->
    case string:str(Value, "~" ++ integer_to_list(Count) ++ "s") of
	0 ->
	    false;
	_Else ->
	    check_referencing(Count-1, Value)
    end;
check_referencing(0, _Value) ->
    true.

wire_textvalidator(Count) ->
    wf:wire(btnFertig, txtAnswer, #validate { validators=[
	#custom{
	    text="Nicht alle Teilfragen werden referenziert.",
	    function=fun(_Tag, Value) ->
		check_referencing(Count, Value)
	    end
	}
    ]}).
	
%event(qtype) ->
%    wf:wire(page1, #fade { speed=500 }),
%    Type = wf:q(lstType),
%    wf:state(qtype, Type),
%    wf:replace(page2,
%	#panel{
%	    id=page2,
%	    body=details_body(Type)
%	}
%    ),
%    wire_numcheck();

event(qtype) ->
    wf:wire(page1, #fade { speed=500 }),

    QuestionID1 = wf:q(lstQuestion),
    QuestionID = list_to_integer(QuestionID1),
    {Type, Questions} = fragedetails(QuestionID),
    Count = length(Questions),

    Question = frage(QuestionID),

    wf:state(questions, Questions),
    wf:state(qtype, Type),
    wf:state(txtQNumber, QuestionID),
    wf:state(txtQText, Question),
    wf:replace(pnlQuestion,
	       #panel{
		 id=pnlQuestion,
		 body=[#label{text="Neue Antwortformulierung hinzufügen für: "}, #label{text=Question}]
		}),
    wf:replace(pnlIntro,
	       #panel { id=pnlIntro }
	       ),
    wf:replace(page2,
	       #panel{
		 id=page2,
		 body=details_body(Type)
		 }
	      ),


    case Type of
	text ->
	    wire_textvalidator(Count);
	_Else ->
	    ok
    end,


    wf:replace(subquestions,
	       #panel{
		 id=subquestions,
		 style="display: none",
		 body=subquestions(Type, Count, Questions)
		}	
	      ),
    wf:wire(subquestions, #show { effect=slide, speed=500 }),
    wf:wire(answertext, #show { effect=slide, speed=500 }),
    wire_subvalidators(Type, Count),
    if
	Type =:= "qtype_text" ->
	    wire_textvalidator(Count);
	true ->
	    ok
    end;


event(fin) ->
    wf:wire(subquestions, #fade { speed=500 }),
    wf:wire(answertext, #fade { speed=500 }),
    wf:wire(pnlIntro, #fade { speed=500 }),
    wf:wire(pnlThanks, #show { effect=slide, speed=500 }),

    Res = try do_db_write() of
	      ok -> ok;
	      _Else -> error
	  catch
	      _:_ -> error
	  end,

    case Res of
	ok ->
	    wf:flash("Ihre Angaben wurde in unsere Datenbank übernommen.");
	_Else2 ->
	    wf:flash("Ich bedaure sehr, es ist ein Fehler beim Schreiben in die Datenbank aufgetreten. Daten wurden nicht geschrieben!")
    end;

event(anotherone) ->
    wf:redirect("/");

event(_Foo) ->
    ok.

assemble_subquestions(_Type=text, Count) when Count > 0 ->
    [wf:q(txtAnswer)] ++ wf:state(questions);
assemble_subquestions(Type=predef, Count) when Count > 0 ->
    assemble_subquestions(Type, Count-1) ++
	[{wf:state("txtQ" ++ integer_to_list(Count)),
	  wf:q("txtA" ++ integer_to_list(Count))}];
assemble_subquestions(_Type, 0) ->
    [].

assemble_subquestions() ->
    Count = length(wf:state(questions)),
    Type = wf:state(qtype),
    assemble_subquestions(Type, Count).

do_db_write() ->
    {ok, C} = pgsql_pool:get_connection(zensus),

    D = assemble_subquestions(),
    V = [
	 wf:state(txtQNumber),
	 wf:state(txtQText),
	 wf:q(txtName),
	 wf:state(qtype),
	 epoch(),
	 base64:encode(term_to_binary(D))
	],
    V1 = [if is_list(I) -> list_to_binary(I); true -> I end || I <- V],
    Query = "INSERT INTO questions
             (qid, question, contributor, question_type, ctime, data)                                                           
             VALUES ($1, $2, $3, $4, $5, $6)",
    Res = try pgsql:equery(C, Query, V1) of
	      {ok, 1} -> ok;
	      _Else -> error
	  catch _:_ ->
		  error
	  end,
    
    pgsql_pool:return_connection(zensus, C),
    Res.
    
epoch() ->
    {A, B, _C} = now(),
    A * 1000000 + B.

autocomplete_enter_event(SearchTerm, _Tag) ->
    Q = "SELECT question FROM questions WHERE lower(question) LIKE $1 LIMIT 10",
    {ok, C} = pgsql_pool:get_connection(zensus),
    SearchTerm1 = string:to_lower(SearchTerm),
    {ok, _, Rows} = pgsql:equery(C, Q, [SearchTerm1 ++ "%"]),
    pgsql_pool:return_connection(zensus, C),
    L2 = [{struct, [{id, I}, {label, I}, {text, I}]} || {I} <- Rows],
    mochijson2:encode(L2).

autocomplete_select_event({struct, _}) ->
    ok.
