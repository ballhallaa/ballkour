#!mainFile "../src/courses/3-paraíso/3-paraíso.opy"

rule "Leaderboard":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator, then a # discord: ID comment to link the player
    lb = []
    # The assisted leaderboard, for runs played in Assist Mode, laid out the same way, with
    # assistedLbRunInfo(rank, date, link) for its runs' info in loadRunInfo
    assistedLb = []
