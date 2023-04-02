// calendar manager agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService (was:CalendarService)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:CalendarService is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    .print("Hello world");
    makeArtifact("calenderService", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    .print("initatiated the calender service thing");
    !reactToUpcomingEvent.

@upcoming_event_listener
+!reactToUpcomingEvent : true <-
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent",  EventStateLst);
    .print("reading upcoming event");
    .nth(0,EventStateLst,EventState); // performs an action that unifies OwnerState with the element of the list OwnerStateLst at index 0
    -+upcoming_event(EventState); // updates the beleif owner_state 
    .wait(5000);
    !reactToUpcomingEvent. // creates the goal !read_owner_state

@upcoming_event
+upcoming_event(Event) : true <- 
    .print("new upcoming event: ", Event);
    .send(personal_assistant, tell, upcoming_event(Event)).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
