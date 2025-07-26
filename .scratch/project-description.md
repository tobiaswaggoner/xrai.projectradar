Ich bin dabei, ein komplett neues Projekt zu starten, nämlich das Projekt "Project Radar".

Dieses Projekt hat eine relativ interessante Infrastruktur. In der Anlage findest du auch ein kurzes Architekturdiagramm, und ich habe das Transkript eines YouTube-Videos, in dem ich ganz grob über das Projekt bereits spreche.

Unsere Aufgabe jetzt ist es, ein erstes Projektbeschreibung zu erstellen, die ganz grob den Scope erfasst, das heißt, nicht funktionale Anforderungen, funktionale Anforderungen und Motivation.

Auf dieser Basis sollten wir in der Lage sein, einen sehr high-level Implementierungsroadmap zu erstellen. 

Das heißt, was ich machen möchte, ist ich möchte jetzt im Prinzip diese dieses Projekt zunächst einmal auf einer reinen Business-Ebene beschreiben, das heißt, was wollen wir mit diesem Projekt erreichen, was ist da die Hauptanteile dran?

Dann möchte ich das ein wenig runter spezifizieren in einem nächsten Schritt.

Und dann möchte ich im Prinzip auf Basis dieses Schrittes anfangen, einen ersten Implementierungsplan zu machen, bevor wir dann in die Implementierung gehen. 

Ich beschreibe das Projekt noch einmal so aus dem Kopf raus.

Die Grundidee des Projektes ist: Ich möchte ein Projektradar bauen für Freelancer-Projekte und für Contracting-Aufträge, das folgendes Problem löst:

Ich bekomme Opportunities über mögliche Projekte auf sehr vielen Kanälen. Es gibt Portale, wo Opportunities gelistet werden, Social Media-Kanäle wie LinkedIn, auf denen Opportunities ich bekomme Opportunities zugeschickt per E-Mail von Agenturen, ich stolper teilweise selber drüber, oder ein Kollege hat irgendwo etwas.

Was ich gerne machen möchte, ist: Ich möchte im Prinzip eine Ingestion Pipeline bauen, die eine Projekt Opportunity, egal auf welchem Kanal sie reingekommen ist, als Text-Junk erstmal als völlig unformatierten Text-Junk entgegennimmt und dann mit wie im Architektur-Diagramm so grob angerissen über eine Ingestion Pipeline mit diverser AI-Magic die Daten extrahiert und quasi in einem persistenten Format zur Verfügung stellt.

Das ist die eine Hälfte, das ist der Ingestion Pipeline. 

Die zweite Hälfte ist dann ein User Interface, das mir erlaubt, diese Ingestions, diese Opportunities dann in Form von einer Pipelining Anwendung zu verarbeiten.

Dazu werde ich gleich noch ein bisschen Skripte dazu, also so grobe Wireframes dazu raus geben. Ich stell mir den Workflow so vor, dass die neu gefundenen Opportunities zunächst mal in einer Art Inbox landen. Von wo aus sie dann noch einmal manuell vorsortiert werden können. Wichtig ist, die KI soll diese Opportunities bereits vorgewichtet haben.

Das heißt, neben dem Input 1, das sind die Opportunities, möchte ich im Prinzip für mich ein Profil hinterlegen, mit dem ich alle meine Skills, alle meine mein CV (beispielsweise mein curriculum vitae), meine aktuelle Präferenzen (das heißt, was mir wichtig ist an einem Projekt) und ähnliche Dinge hinterlege.

Ich möchte dann im Prinzip eine Vorgewichtung haben über eine KI-Pipeline, also über ein Large Language Model, das im Prinzip die hereinkommende Opportunity gegen mein Profil und gegen meine Wünsche abgleicht und dann im Prinzip ein Gewicht gibt, wie interessant das sein könnte.

Diese vorgewichteten Dinge mit extrahierten Daten möchte ich jetzt in meiner Inbox sehen und darauf hin bewerten, ob ich generell Interesse habe, dieses Projekt weiter zu verfolgen, oder nicht.

Und dann, wenn ja, landet das quasi in einer im Projekt-Backlog drin mit dieser vorgegebenen Gewichtung.

Dieses Projekt-Backlog möchte ich dann ähnlich wie ein Jira-Projekt oder wie ein Scrum-Projekt das Backlog gewichten können, indem ich prinzip die Opportunities manuell per Drag-and-Drop hoch- und runter schiebe.

Das heißt, wir brauchen eine sortierte Liste, die diese Opportunities enthält, und aus diesem Backlog raus möchte ich dann im Prinzip die Akquise starten können.

Das heißt, ich brauche irgendwie eine Aktivierung, und für alle Projekte, die in der Akquise sind, möchte ich dann ein Canvas übersicht haben, als eine Art Pipeline, die die Projekte in diversen noch zu definierenden Statusanzeigen, so dass ich im Prinzip eine große Zahl von Projekten in barer Anbahnung gleichzeitig überwachen kann 

So, wenn dieses Projekt dann so weit fertig ist, ergibt sich hieraus die Möglichkeit in weiteren Schritten das ist aber dann Zukunft hier, beispielsweise ein CRM draufzubauen.

Das heißt, man kann diverse Dinge dann automatisieren.

Das heißt, ich kann sowohl die Kommunikation unterstützen, wir können E-Mail-Postfächer anbinden, so dass die ausgehenden E-Mails darin zugewiesen werden.

Wir können Agenturen, Firmen und Ansprechpartner extrahieren, um eine bessere Übersicht zu bekommen.

Das sind alles Dinge, die auf Basis dieser Anwendung nachher ergänzt werden können. Wichtig: Der Scope dieses Projekts besteht ausschließlich aus dem, was ich gerade beschrieben habe.

Also, um es kurz zusammenzufassen: Ich möchte zum einen eine Ingestion Pipeline haben, die im Prinzip ausgehend von einem Text Junk diese Datenextraktion inklusive Deduplizierung, Datenextraktion und Gewichtung durch ein Large Language Model vornimmt.

Und der Input für diese Pipeline ist in unserem Prototyp zunächst einmal schlicht und ergreifend ein UI-Element, wo ich im Prinzip zwei Felder haben möchte:

Ich möchte die Quelle angeben können in Form von einer URL oder auch in einem normalen Text-String.

Das muss nicht unbedingt nur URL sein, aber möglichst eine eindeutige Quelle, die man wieder rückverfolgen kann.

Und einem kompletten Plain-Text-Feld, wo HTML drin stehen kann, wo Markdown drin stehen kann – das ist im Prinzip aus Sicht der Anwendung irrelevant. 

So, im Scope ist nur das UI. Out of scope sind Crawler. Das heißt, nachdem wir dieses UI fertig haben, kann man in einem nächsten Schritt Crawler implementieren, die zum Beispiel über diverse Freelancing-Plattformen automatisch Opportunities finden.

Wir können einen Crawler implementieren, der eingehende E-Mails scannt auf Opportunities. Wir können ein Crawler implementieren, der Social Media-Anfragen verarbeitet, wie in LinkedIn, oder auch aktiv sucht. Das ist alles Zukunftsmusik.

Das heißt, das ist das interessante, dann für die Skalierung, dass wir aus diesem Projekt wirklich ein Projekt-Radar machen. Radar in der Form, dass das System mich aktiv über geniale Opportunities informieren kann. 

Nachdem wir diese Anwendung jetzt beschrieben haben, möchte ich jetzt noch ein paar Worte zur Architektur loswerden. In dem Diagramm, was ich hier mit in dieses in diesem Prompt reinpaste, ist schon ersichtlich, dass wir ein paar architekturelle Entscheidungen schon vorab getroffen haben:
- Soll die gesamte Architektur auf Basis einer reaktiven Nachrichten-getriebenen Microservice-Architektur bestehen.
- Die einzelnen Microservices sollen kontinuierlich sein, das heißt, wir brauchen einen Docker-Environment, und wir werden die Kommunikation zwischen den einzelnen Komponenten über einen Message Bus realisieren. Wir verwenden dazu RabbitMQ.

Die Persistenz erfolgt in einem relationalen Datenbanksystem, das heißt, wir werden bewusst ein relationales Datenbanksystem mit einem JSON-Field verwenden. Dazu werden wir Postgres verwenden, und im Prinzip wird Postgres unser go-to-Persistenz-Layer für alle Komponenten sein.

Da die Komponenten aber in Microservice-Art und Weise realisiert sind, ist natürlich die Persistenz an jeder Stelle austauschbar, aber unser go-to wird Postgres. 

Was den Techstack angeht, werden wir die Anwendung als Backend-Anwendung entwickeln. Alle Backend-Anwendungen werden.NET basiert sein, das heißt, wir gehen auf eine.NET 8, die zurzeit noch die LTS-Version, die long-term-stable-Version ist.

Das wird eine.NET 8-Anwendung werden. Vielleicht werden wir mittelfristig auf.NET 10 migrieren, aber stehen wir starten mit.NET 8. 

Und jetzt kommt noch eine ganz wichtige Anmerkung zum Text:

Die State-Verwaltung, die dauerhafte Persistenz erfolgt via Event Sourcing, und wir werden ein CQS-Pattern haben für unsere User Interface. Das heißt, der gesamte State der Anwendung wird in einem noch zu entwickelnden Event-Store gespeichert.

Dort ist ein Teil unserer Aufgabe, einen Event-Store zu entwickeln, assistiert werden. Ich habe dazu einige Papers, die nachher die Werte mitgeben, wie der Event-Store implementiert werden kann. 

Für das Frontend bin ich momentan noch ein wenig unentschlossen. Ich denke, wir werden zumindest das Prototyping mit Next.js machen.

Das heißt, ich möchte das Prototyping gerne mit v0 von Vercel machen, das automatisch immer Next.js + Tailwind Anwendungen erzeugt, weil ich da ein bisschen Erfahrung damit habe und weil ich sonst kein UI-Mann bin. Der Prototyp wird hieraus generiert werden. Eigentlich wäre es schön, homogen zu bleiben und beispielsweise einen Blazor Frontend zu machen.

Aber ich bin mir noch nicht sicher, ob wir hier nicht irgendwo eine Lücke rein laufen. Das heißt, für den jetzigen Zeitpunkt lassen wir noch offen, ob die Frontend-Technologie Next.js/react basiert sein wird oder dort nicht Blazor basiert. 

