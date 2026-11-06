#!mainFile "../main.opy"
#!rulePrefix "Orb Checkpoint"

# A checkpoint with orbs (cpData[5]) has to be left with a grapple, after which the player may
# roll along the ground and jump as long as they stay fast, until they have every orb. After
# that, any landing but the next checkpoint is a Missed Checkpoint. Reaching the next checkpoint
# without them all is a mistake too (Completion: Checkpoint (No Skipping)).


# The orbs not grabbed yet, and of those, the ones the ball is touching. The ball's centre is
# 0.7 m up from its position, and in-game a size-1 orb visibly touches the ball 1.24 m from
# there. The reach is a touch more forgiving than that: the orb's radius plus 0.3 m. Unlike
# Fasteroid's fork of the Giga editor, the eyes aren't checked: in ball form they sit 1.83 m
# up, above the ball.
macro orbsLeft(player):
    player.cpData[5].filter(lambda orb, i: not hasGrabbedOrb(player, i))


macro orbsTouched(player):
    orbsLeft(player).filter(
        lambda orb: distance(player.getPosition() + vect(0, 0.7, 0), orb)
        <= player.cpData[6] + 0.3
    )


rule "No Grapple":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[12] == false
    @Condition eventPlayer.cpData[13] == false
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )

    eventPlayer.isLoading = true
    addMistake()
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "Too Slow":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[13] == true
    # Only on the ground before the last orb: after it every landing is a mistake anyway, and a
    # jump up to an orb can slow down in the air
    @Condition hasAllOrbs(eventPlayer) == false
    @Condition eventPlayer.isOnGround() == true
    @Condition eventPlayer.getSpeed() <= 10
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )

    eventPlayer.isLoading = true
    addMistake()
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "Grab Orb":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.cpData[5] != null
    @Condition len(orbsTouched(eventPlayer)) > 0
    # The last one only in the air, so rolling through it isn't then read as landing after it
    @Condition (not eventPlayer.isOnGround() or len(orbsLeft(eventPlayer)) > 1) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.spectating[0] == false

    eventPlayer.cpData[16] = eventPlayer.cpData[16] + 2 ** eventPlayer.cpData[5].index(
        orbsTouched(eventPlayer)[0]
    )
    playEffect(eventPlayer, DynamicEffect.BUFF_EXPLOSION_SOUND, null, eventPlayer, 100)
    # Another orb touched in the same tick doesn't retrigger the rule
    wait()
    if RULE_CONDITION:
        loop()
