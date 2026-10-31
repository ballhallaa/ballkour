// OverPy runs this on the compiled script (#!postCompileHook in ballkour.opy), as Overwatch freezes
// while it reads a pasted script in. It only changes how the script is written, never an element:
// no comments, indentation or rule names, and variables and subroutines get the shortest names.
// Dev builds stay readable for the Workshop editor and Inspector.

// The version is in the description, as a dev version ends in -dev
if (!/-dev \\n\\nLatest Code/.test(content)) {
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
                return 'rule ("") {';
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
