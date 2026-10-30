"""Exercise the real Swift client against the Objective-C host, using fake editor objects."""
import json
import subprocess
import sys

fixture = subprocess.Popen([sys.argv[1], "--serve"], stdout=subprocess.PIPE, text=True)
try:
    assert fixture.stdout.readline().strip() == "READY"

    def request(*arguments):
        result = subprocess.run(
            [sys.argv[2], "--pid", str(fixture.pid), *arguments],
            capture_output=True, text=True, timeout=15, check=True,
        )
        return json.loads(result.stdout)

    diagnostics = request("diagnostics")
    assert diagnostics["hasActiveTab"] is True, diagnostics
    assert request("commands")["count"] == 512
    assert request("audit", "CommentUncomment")["entries"][0]["available"] is True
    result = request("execute", "Xcode.IDEPegasusSourceEditor.CmdDefinition.CommentUncomment")
    assert result["targetClass"] == "FixtureEditor" and result["status"] == "dispatched"
    assert request("execute", "Xcode.IDEKit.CmdDefinition.Build")["route"] == "workspaceTab"
    print("PASS: Swift CLI → CFMessagePort → Objective-C host → editor/workspace dispatch")
finally:
    fixture.terminate()
    fixture.wait(timeout=5)
