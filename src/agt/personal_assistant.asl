// personal assistant agent

/* inital beliefs */
rank(0).


/*inference rules */
handle("lights") :- rank(1).
handle("blinds") :- rank(0).

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    makeArtifact("dweeter", "room.DweetArtifact", [], Dweeter);
    focus(Dweeter).


+!get_help_from_a_friend : true <-
    .print("sending dweet");
    sendDweet("please help me to wake up my user");
    !upgrade_rank.

+upcoming_event("now") : owner_state("asleep") & not refuse("wake-up")[source(blinds_controller),source(lights_controller)] <-
    .print("starting wake-up routine");
    !wake_up_routine.

+!wake_up_routine : refuse("wake-up")[source(blinds_controller),source(lights_controller)]<-
    .print("okay, need outside help");
    !get_help_from_a_friend.

+!wake_up_routine : owner_state("asleep") & not refuse("wake-up")[source(blinds_controller),source(lights_controller)] <-
    .broadcast(tell, cfp("wake-up"));
    .wait(4000);
    !wake_up_routine.

+!wake_up_routine : owner_state("awake") <-
    .print("awake, but at what cost").

+owner_state("asleep") : owner_state("asleep") <-
    .print("starting wake-up routine");
    !wake_up_routine.

+propose(Proposal)[cfp("wake-up"), source(Controller)] : true <-
    .print("evaluating proposal:", Proposal);
    -propose(Proposal)[cfp("wake-up"), source(Controller)];
    !handle_proposal(Proposal)[source(Controller)].


+refuse(Proposal)[cfp("wake-up")]  : true <-
    .print("got refused: ", Proposal).

+upcoming_event("now") : owner_state("awake") <-
    .print("enjoy your event").


@upgrade_rank
+!upgrade_rank : true <-
    ?rank(Old);
    .print("old Rank", Old);
    !get_new_rank(Old, New);
    .print("new Rank", New);
    -rank(Old);
    +rank(New).

@get_new_rank
+!get_new_rank(Old, New): true <-
    New = ( Old + 1 ) mod 3.

+!handle_proposal(Proposal)[source(Controller)] : handle(ProposalInfered) & not (ProposalInfered == Proposal) <-
    .print("preparing to refuse the following plan: ", Proposal);
    .send(Controller, tell, reject_proposal(Proposal)).

+!handle_proposal(Proposal)[source(Controller)] : handle(ProposalInfered) & (ProposalInfered == Proposal) <-
    .print("preparing to accpet the following proposal: ", Proposal);
    .send(Controller, tell, accept_proposal(Proposal)).

+failure(Proposal)[source(Controller)] : true <- 
    .print("my fellow agent failed for proposal ", Proposal, " by ", Controller);
    !upgrade_rank.

+inform_done(Proposal)[source(Controller)]  : true <- 
    .print("my fellow agent finished the action for proposal ", Proposal, " by ", Controller);
    !upgrade_rank.

+inform_result(Result)[source(Controller)]  : true <- 
    .print("received the following result ", Result, " by ", Controller).


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }