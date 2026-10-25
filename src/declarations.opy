# Settings
globalvar settings_
# The Hint Recorder only exists in dev builds (a VERSION ending in -dev), so release builds don't spend elements on it
macro HINT_RECORDER = strContains(VERSION, "-dev")
macro isHintRecorderOn = HINT_RECORDER and settings_[2]

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
globalvar ddBots
globalvar dd

# Players
globalvar players
globalvar hostPlayerName
globalvar nameplateObjs
globalvar tinyNameplateObjs

# Spectating
globalvar playerToEnableFreecam
globalvar freecamStartPos

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

# Checkpoints
playervar cpData
playervar isCpTimerActive
playervar cpStartTime
playervar cpTime
playervar cpTimeFormatted
playervar cpTotalTimeFormatted
playervar viewCp

# Hint Playback
playervar isHintOn
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

# Spectating
playervar spectating
playervar firstPersonSpectatingTime
playervar spectateTargets

playervar index 127

# Player
subroutine showCpNameplate

# Lobby
subroutine loadLobby

# Run
subroutine newRun
subroutine updateStats
subroutine pauseRun

# Checkpoints
subroutine loadCpData
subroutine setCpAbilities
subroutine cpResetPlayer
subroutine faceNextCp

# Hints
subroutine saveHintRoute

# Time Formatting
subroutine formatTime

# Spectating
subroutine enableSpectator
subroutine disableSpectator
subroutine enableFreecam
subroutine enableFreecamForSpectators
subroutine syncSpectatorCps
subroutine reattachToSpectatingTarget
subroutine enableFirstPersonSpectator
