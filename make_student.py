import re, sys
src, dst = sys.argv[1], sys.argv[2]
txt = open(src, encoding="utf-8").read()
txt = txt.replace(" — CORRIGÉ", "")
# answers -> placeholder
txt = re.sub(r"<!-- REP -->\n.*?<!-- /REP -->", "> *Votre réponse :*\n>\n> ", txt, flags=re.S)
# teacher-only chunks (checkpoint saving)
txt = re.sub(r"```\{r [a-z]+-save, include = FALSE\}\n.*?```\n", "", txt, flags=re.S)
out = []
holes = 0
for line in txt.split("\n"):
    m = re.match(r"^(\s*)(.*?)\s+#@ (.*)$", line)
    if m:
        out.append(m.group(1) + m.group(3)); holes += 1
    else:
        out.append(line)
open(dst, "w", encoding="utf-8").write("\n".join(out))
print("trous:", holes, "| réponses restantes:", "\n".join(out).count("<!-- REP"), "| '#@' restants:", "\n".join(out).count("#@"))

# version corrigée propre (sans les marqueurs #@)
if len(sys.argv) > 3:
    c = open(src, encoding="utf-8").read()
    c = re.sub(r"\s+#@ .*$", "", c, flags=re.M)
    c = c.replace("<!-- REP -->\n", "").replace("<!-- /REP -->\n", "")
    open(sys.argv[3], "w", encoding="utf-8").write(c)
    print("corrigé écrit; '#@' restants:", c.count("#@"))
