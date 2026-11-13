// OverPy runs this on the compiled script (#!postCompileHook in ballkour.opy), as Overwatch freezes
// while it reads a pasted script in. It only changes how the script is written, never an element:
// no comments, indentation or rule names (but Source Code's), and variables and subroutines get the
// shortest names.
// Builds with a +tag on VERSION (declarations.opy) stay readable for the Workshop editor and Inspector.

// One change to an element, in every build: OverPy gives __languageIndex__ (#!translateWithPlayerVar
// in ballkour.opy) a starting value in an "Initialize player variables" rule, which only its own
// language detection needs. Player: Joins does the detection instead, so the rule comes out, as long
// as that's all it does, which saves an eachPlayer rule.
content = content.replace(
    /\n\s*rule \("Initialize player variables"\) \{\s*event \{\s*Ongoing - Each Player;\s*All;\s*All;\s*\}\s*actions \{\s*Set Player Variable\(Event Player, __languageIndex__, 0\.1\);\s*\}\s*\}/,
    ""
);

// The Source Code rule (match.opy) goes first in every build, above OverPy's own rules, so its link
// is the first thing in the script. A release build keeps its name too (below).
var sourceCodeRule = /\nrule \("Source Code"\) \{\n[\s\S]*?\n\}\n/.exec(content);
if (sourceCodeRule) {
    content = content.replace(sourceCodeRule[0], "");
    var firstRule = content.indexOf("\nrule (") + 1;
    content =
        content.slice(0, firstRule) + sourceCodeRule[0].slice(1) + "\n" + content.slice(firstRule);
}

// The version is in the description, which a tagged version ends in +tag
if (!/\+\S+ \\n\\nLatest Code/.test(content)) {
    var STRING_OR_NAME = /"[^"\\]*(?:\\.[^"\\]*)*"|[A-Za-z_][A-Za-z0-9_]*/g;
    var COMMENT = /^"[^"\\]*(?:\\.[^"\\]*)*"$/;
    var DECLARATION = /^\d+: (\S+)$/;

    var lines = content.split("\n").map(function (line) {
        return line.trim();
    });
    var variablesStart = lines.indexOf("variables {");
    var subroutinesStart = lines.indexOf("subroutines {");
    var rulesStart = lines.indexOf("}", subroutinesStart);

    function declaredIn(start, end) {
        var names = [];
        lines.slice(start, end).forEach(function (line) {
            var declared = DECLARATION.exec(line);
            if (declared && names.indexOf(declared[1]) < 0) {
                names.push(declared[1]);
            }
        });
        return names;
    }

    var uses = new Map();
    lines.slice(rulesStart).forEach(function (line) {
        (line.match(STRING_OR_NAME) || []).forEach(function (token) {
            uses.set(token, (uses.get(token) || 0) + 1);
        });
    });
    function mostUsedFirst(names) {
        return names.sort(function (a, b) {
            return (uses.get(b) || 0) - (uses.get(a) || 0);
        });
    }

    // A-Z, then AA, AB..., the names Overwatch gives variables itself
    var shortNames = new Map();
    function nextShortName() {
        var n = shortNames.size;
        var letter = function (i) {
            return String.fromCharCode(65 + i);
        };
        return n < 26 ? letter(n) : letter(Math.floor(n / 26) - 1) + letter(n % 26);
    }
    mostUsedFirst(declaredIn(variablesStart, subroutinesStart))
        .concat(mostUsedFirst(declaredIn(subroutinesStart, rulesStart)))
        .forEach(function (name) {
            shortNames.set(name, nextShortName());
        });

    lines
        .filter(function (line, i) {
            return i < variablesStart || !(COMMENT.test(line) || line.startsWith("//"));
        })
        .map(function (line, i) {
            if (i < variablesStart) {
                return line;
            }
            if (line.startsWith("rule (")) {
                return line === 'rule ("Source Code") {' ? line : 'rule ("") {';
            }
            return line.replace(STRING_OR_NAME, function (token) {
                return shortNames.get(token) || token;
            });
        })
        .join("\n")
        .toString();
} else {
    content;
}
