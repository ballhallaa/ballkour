#!mainFile "../src/courses/5-practice-range/5-practice-range.opy"

rule "Leaderboard":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator, then a # discord: ID comment to link the player
    lb = []
    # The assisted leaderboard, for runs played in Assist Mode, laid out the same way, with
    # assistedLbRunInfo(rank, date, link) for its runs' info in loadRunInfo
    assistedLb = []
