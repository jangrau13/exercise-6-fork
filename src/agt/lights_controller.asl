// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    .print("Hello world").

@raise_blinds
+should_wake_up_owner(State) : should_wake_up_owner(1) & lights("off") <- 
    .print("The lights are off and it is time to wake up the owner with light").

@set_lights_state
+!set_lights_state(State) : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",  ["https://www.w3.org/2019/wot/json-schema#StringSchema"], [State])[ArtId];
    -+lights(State);
    .print("setting state: ", State).

@put_lights_on
+!lights_on : true <-
    !set_blinds_state("lowered").

@put_lights_off
+!lights_off : true <-
    .print("raising the blinds");
    !set_blinds_state("off").

@lights
+lights(State) : true <-
    .print("state ", State);
    .send(personal_assistant, tell, lights(State)).

@cfp_wake_up_reject
+cfp("wake-up")[source(Controller)] : lights("on") <- 
    .print("received cfp for waking up, but lights are already on or deadline is expired");
    .send(Controller, tell, refuse("wake-up")).

@cfp_wake_up_propose
+cfp("wake-up")[source(Controller)] :  lights("off") <- 
    .print("received cfp for waking up and sending proposal ", "lights");
    .send(Controller, tell, propose("lights")[cfp("wake-up")]).

@got_a_rejection
+reject_proposal(Proposal)[source(Controller)] : true <-
    .print("I dare you ", Controller);
    .print("I double dare you ", Controller).

@got_an_accept
+accept_proposal(Proposal)[source(Controller)] : true <-
    .print("Thank you ", Controller, " for your trust in me.");
    !execute_proposal(Proposal)[source(Controller)].

@executing_proposal
+!execute_proposal(Proposal)[source(Controller)]: true <-
    .print("executing ", Proposal, " for ", Controller);
    !lights_on;
    +sending_success(Proposal)[source(Controller)].

-!lights_on : true <-
    .send(personal_assistant, tell, failure("blinds")).

@sending_failure
+send_failure(Proposal)[source(Controller)] : true <-
    .print("sending failure");
    .send(Controller, tell, failure(Proposal)).

@sending_success
+sending_success(Proposal)[source(Controller)]: true <-
    .print("sending success");
    .send(Controller, tell, inform_done(Proposal));
    ?lights(Result);
    .print("current result state ", Result);
    .send(Controller, tell, inform_result(Result)).



/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }