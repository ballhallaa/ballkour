# Settings
globalvar settings_
# Debug, Server Load, Lobby Stats and the Hint Recorder only exist in dev builds (a VERSION ending in -dev), so release builds don't spend elements on them
macro DEV = strContains(VERSION, "-dev")
macro isDebugOn = DEV and settings_[0]
macro isServerLoadOn = DEV and settings_[3]
macro isLobbyStatsOn = DEV and settings_[1]
macro isHintRecorderOn = DEV and settings_[2]

# Leaderboard
globalvar lb
globalvar lbPos
globalvar lbObj
globalvar lbObjFormatted
globalvar lbRunCount
globalvar lbRunText
globalvar timeToBeat
globalvar timeToBeatFormatted

# Checkpoints
globalvar cps
# -1 until Checkpoint: Expand Data sets it, so nobody counts as being on the final checkpoint
globalvar lastCp = -1
globalvar cpDefaults

# Hints
globalvar hintData
globalvar hintScratch
globalvar hintDecodeIndex
globalvar hintRoutes
globalvar hintTimes
globalvar hintActions
globalvar hintAnchors
globalvar hintColors

# Lobby
globalvar lobbyData
globalvar lobbyStats

# Match
globalvar elapsedTime
globalvar elapsedTimeFormatted
globalvar dedBots
globalvar ded
globalvar serverLoadAvg

# Players
globalvar players
globalvar hostPlayerName
globalvar nameplateObjs
globalvar tinyNameplateObjs
globalvar scorecard
globalvar scorecardShort
globalvar scorecardDirty
globalvar scorecardRunners
globalvar scorecardRow
globalvar scorecardTime
globalvar topRuns = []
globalvar topRunsScratch
globalvar topRunsText

# Spectating
globalvar playerToEnableFreecam
globalvar freecamStartPos
globalvar freecamQueue = []

# Translated HUD Text
# Each HUD text's translations are stored here once and shown with _(), instead of written into the HUD text.
# Overwatch reprocesses every HUD text's definition every 5s, and a translated string puts every language
# into it, which took that spike from ~66% to ~90% server load. A stored string can't have {} placeholders,
# so its arguments are @0, @1... markers, filled in with .replace("@0", value) where it's shown.
globalvar ctrlsHudText = []
globalvar freemodeHudText
globalvar hintsHudText = []
globalvar runHudText
globalvar counterHudText = []
globalvar splitsHudText = []
globalvar spectatorHudText = []
globalvar completionHudText = []
globalvar scorecardHudText = []
globalvar topRunsHudText
globalvar lobbyHudText = []

globalvar index 127

# Player
playervar isLoading
playervar isInLobby
playervar nameplate
playervar isTiny

# Leaderboard
playervar lbAim
playervar lbInfoRow

# Run
playervar isRunLoaded
playervar isRunLegit
playervar isRunPaused
playervar isRunFinished
playervar isTimerActive
playervar runCurrentCp
playervar runTime
playervar runTimeFormatted
playervar runMistakes
playervar runFinalTimeFormatted
playervar runFinalMistakes
playervar runCount
playervar isViewingRunCompletionText
playervar viewRunner

# Checkpoints
playervar cpData
playervar isCpTimerActive
playervar cpTime
playervar cpTimeFormatted
playervar cpStartMistakes
playervar cpAttempts
playervar viewCp

# Splits
playervar splitStart
playervar splitTime
playervar splitTimeFormatted
playervar splitBests
playervar splitTotals
playervar splitClears
playervar splitStatsFormatted
playervar splitDelta
playervar isShowingSplitDelta
playervar splitCpBest
playervar attemptBests
playervar attemptTotals
playervar attemptCpBest
playervar splitDiff
playervar splitResult

# Pace
playervar paceEta
playervar paceEtaFormatted
playervar paceSplit
playervar paceSplitTotal
playervar paceSplitClears

# Hint Playback
playervar isHintOn
playervar isHintAutoOn
playervar isHintPlaying
playervar isViewingHintInfo
playervar hintPlayCp
playervar hintKeyframes
playervar hintKeyframeTimes
playervar hintIndex
playervar hintStep
playervar hintTime
playervar hintPos
playervar hintS
playervar hintSpline
playervar hintColor
playervar hintAnchor

# Hint Recording
playervar hintRecording
playervar hintRecordCp
playervar hintRecordStart
playervar hintRecordLast
playervar hintRecordTimes
playervar hintRecordActions
playervar hintActionStarts
playervar hintRecordAnchors
playervar hintGrappleAnchor

# Time Formatting
playervar timeToFormat
playervar timeFormatted

# Controls
playervar isViewingCtrlsHud
playervar isInFreemode
playervar isScorecardHidden
playervar scorecardKey

# Spectating
playervar spectating
playervar firstPersonSpectatingTime
playervar spectateTargets
playervar heroSwapTime

playervar index 127

# Player
subroutine showCpNameplate

# Lobby
subroutine loadLobby
subroutine showRunInfo
# Each course's leaderboard has its own, if it has runs
subroutine loadRunInfo

# Run
subroutine newRun
subroutine resetRun
subroutine updateStats
subroutine pauseRun

# Checkpoints
subroutine loadCpData
subroutine setCpAbilities
subroutine cpResetPlayer
subroutine faceNextCp

# Splits
subroutine recordSplit
subroutine recordTopRun
subroutine formatSplitResult

# Pace
subroutine loadPace

# Hints
subroutine saveHintRoute
subroutine resetCpMistakes

# Time Formatting
subroutine formatTime

# Spectating
subroutine enableSpectator
subroutine disableSpectator
subroutine enableFreecam
subroutine swapToJetpackCat
subroutine swapToWreckingBall
subroutine enableFreecamForSpectators
subroutine syncSpectatorCps
subroutine reattachToSpectatingTarget
subroutine enableFirstPersonSpectator


# Run
# Every mistake also ends an attempt at the CP
macro addMistake():
    eventPlayer.runMistakes++
    eventPlayer.cpAttempts[eventPlayer.runCurrentCp]++


# Leaderboard
# A run's leaderboard row, submission date and video link, for the players who opened it
# from its row (Lobby: Run Info Input). The course leaderboards use it, so it's defined here.
# Only open runs get their text, as every text's definition adds to the server's load.
# Workshop text is uppercase and video links aren't, so this overlays progress bar texts,
# which can show lowercase. The row is a stored string, which isn't spread out like the
# literal text: each of the overlaid texts draws all of it.
# It follows the player's camera: the blank lines lift it toward the top of the screen
# and push its progress bar off the screen. The hide line is a stored translation, so like
# the row it's drawn by every overlaid text, and its key name needs the text reevaluated.
macro lbRunInfo(rank, date, link):
    if any([player.lbInfoRow == rank for player in getAllPlayers()]):
        createCasedProgressBarIwt(
            3,
            getAllPlayers().filter(lambda localPlayer: localPlayer.lbInfoRow == rank),
            (
                "\n\n\n\n\n\n\n\n\n{}"
                "\n<fgFFFFFFFF>{}</fg>"
                "\n<fgFFFFFFFF>{}</fg>"
                "\n\n{}\n\n\n\n\n\n\n"
            ).format(
                lbRunText[rank],
                date,
                link,
                _(lobbyHudText[1]).replace("@0", inputBindingString(Button.INTERACT))
            ),
            updateEveryFrame(
                localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 10
            ),
            1,
            Clip.NONE,
            rgb(230, 151, 0),
            ProgressWorldTextReeval.VISIBILITY_POSITION_AND_VALUES
        )
