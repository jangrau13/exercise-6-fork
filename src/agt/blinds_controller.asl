// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 
 
// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url, true], ArtId);
    .print("Hello world").

@raise_blinds
+should_wake_up_owner(State) : should_wake_up_owner(1) & blinds("lowered") <- 
    .print("The blinds are lowered and it is time to wake up the owner with the blinds").

@set_blinds_state
+!set_blinds_state(State) : true <-
    .print("invoking raising action");
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",  ["https://www.w3.org/2019/wot/json-schema#StringSchema"],["raised"])[ArtId];
    -+blinds(State);
    .print("setting state: ", State).

@exec_lower_blinds
+!lower_blinds : true <-
    !set_blinds_state("lowered").

@exec_raise_blinds
+!raise_blinds : true <-
    .print("raising the blinds");
    !set_blinds_state("raised").

@blinds
+blinds(State) : true <-
    .print("state ", State);
    .send(personal_assistant, tell, blinds(State)).

@cfp_wake_up_reject
+cfp("wake-up")[source(Controller)] : blinds("raised") <- 
    .print("received cfp for waking up, but blinds are already raised or deadline is expired");
    .send(Controller, tell, refuse("wake-up")).

@cfp_wake_up_propose
+cfp("wake-up")[source(Controller)] :  blinds("lowered") <- 
    .print("received cfp for waking up and sending proposal ", "blinds");
    .send(Controller, tell, propose("blinds")[cfp("wake-up")]).

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
    !raise_blinds;
    +sending_success(Proposal)[source(Controller)].


@sending_failure
+send_failure(Proposal)[source(Controller)] : true <-
    .print("sending failure");
    .send(Controller, tell, failure(Proposal)).

@sending_success
+sending_success(Proposal)[source(Controller)]: true <-
    .print("sending success");
    .send(Controller, tell, inform_done(Proposal));
    ?blinds(Result);
    .print("current result state ", Result);
    .send(Controller, tell, inform_result(Result)).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }