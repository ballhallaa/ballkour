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
globalvar splitsHudText = []
globalvar spectatorHudText = []
globalvar completionHudText = []
globalvar scorecardHudText = []
globalvar topRunsHudText

globalvar index 127

# Player
playervar isLoading
playervar isInLobby
playervar nameplate
playervar isTiny

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
playervar isViewingRunCompletionText
playervar viewRunner

# Checkpoints
playervar cpData
playervar isCpTimerActive
playervar cpTime
playervar cpTimeFormatted
playervar cpStartMistakes
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
