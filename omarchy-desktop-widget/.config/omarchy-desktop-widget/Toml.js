.pragma library

// Minimal TOML subset parser: [sections], key = string|int|float|bool|array.
// Enough for config.toml; not a full TOML implementation.

function parse(text) {
  var out = {};
  var section = out;
  var lines = String(text || "").split(/\r?\n/);
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].replace(/\s+#.*$/, "").trim();
    if (!line) continue;
    if (line.charAt(0) === "[") {
      var name = line.replace(/^\[+/, "").replace(/\]+$/, "").trim();
      if (!out[name]) out[name] = {};
      section = out[name];
      continue;
    }
    var eq = line.indexOf("=");
    if (eq < 0) continue;
    var k = line.slice(0, eq).trim();
    var v = line.slice(eq + 1).trim();
    section[k] = value(v);
  }
  return out;
}

function value(v) {
  if (v.length >= 2 && (v.charAt(0) === '"' || v.charAt(0) === "'"))
    return v.slice(1, -1);
  if (v === "true") return true;
  if (v === "false") return false;
  if (/^[+-]?[0-9]+$/.test(v)) return parseInt(v, 10);
  if (/^[+-]?[0-9]*\.[0-9]+$/.test(v)) return parseFloat(v);
  if (v.charAt(0) === "[" && v.charAt(v.length - 1) === "]") {
    var inner = v.slice(1, -1).trim();
    if (!inner) return [];
    var parts = inner.split(",");
    var arr = [];
    for (var i = 0; i < parts.length; i++) arr.push(value(parts[i].trim()));
    return arr;
  }
  return v;
}
