#!mainFile "main.opy"
#!setupTags
# Translated in translations/<language>.po (see tools/translations.py)
#!translations en de es fr it ja ko pl pt ru th tr zh_cn zh_tw
#!disableTranslationSourceLines
#!useVariableForCompressionAlphabet
#!rulePrefixTemplate f"{$prefix}: {$rule}" if $prefix and $rule else $rule

#!include "engine/match.opy"
#!include "engine/players.opy"
#!include "engine/lobby.opy"
#!include "engine/run.opy"
#!include "engine/checkpoints.opy"
#!include "engine/hints.opy"
#!include "engine/hint-recorder.opy"
#!include "engine/timers.opy"
#!include "engine/splits.opy"
#!include "engine/movement.opy"
#!include "engine/mistakes.opy"
#!include "engine/bounce-checkpoints.opy"
#!include "engine/completion.opy"
#!include "engine/controls.opy"
