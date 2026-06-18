# Auto-start CP listener (PID file prevents duplicates)
_CP_PID=/tmp/cp_listener.pid
if [ -f "$_CP_PID" ] && kill -0 $(cat "$_CP_PID") 2>/dev/null; then
    : # already running
else
    python3 ~/scripts/cp_listener.py >> /tmp/cp_listener.log 2>&1 &
    echo $! > "$_CP_PID"
fi

# Watch listener output
cplog() { tail -f /tmp/cp_listener.log; }

# Restart listener manually
cpstart() {
    kill $(cat /tmp/cp_listener.pid 2>/dev/null) 2>/dev/null
    python3 ~/scripts/cp_listener.py >> /tmp/cp_listener.log 2>&1 &
    echo $! > /tmp/cp_listener.pid
    echo "CP listener restarted"
}

# Open problem (moves from inbox if needed, creates if new)
# Usage: cf rating_800_1000/4A
cf() {
    if [ -z "$1" ]; then
        echo "Usage: cf <rating_folder>/<problem_id>"
        return 1
    fi
    local CF="$HOME/C++/CompetitiveProgramming/Codeforces"
    local folder="$(dirname $1)"
    local pid="$(basename $1)"
    local dest="$CF/$folder/$pid"
    local inbox="$CF/inbox"

    mkdir -p "$dest/test"

    # Move from inbox if listener staged it there
    [ -f "$inbox/$pid.cpp" ]      && mv "$inbox/$pid.cpp"      "$dest/"
    [ -f "$inbox/$pid.meta" ]     && mv "$inbox/$pid.meta"     "$dest/"
    [ -f "$inbox/${pid}_notes.md" ] && mv "$inbox/${pid}_notes.md" "$dest/"
    [ -d "$inbox/test_$pid/test" ] && mv "$inbox/test_$pid/test/"* "$dest/test/" 2>/dev/null && rm -rf "$inbox/test_$pid"

    # Create from template if still doesn't exist
    [ ! -f "$dest/$pid.cpp" ] && cp "$HOME/C++/CompetitiveProgramming/templates/template.cpp" "$dest/$pid.cpp"

    nvim "$dest/$pid.cpp"
}

# Test solution
# Usage: cftest rating_800_1000/4A
cftest() {
    if [ -z "$1" ]; then
        echo "Usage: cftest <rating_folder>/<problem_id>"
        return 1
    fi
    local CF="$HOME/C++/CompetitiveProgramming/Codeforces"
    local folder="$(dirname $1)"
    local pid="$(basename $1)"
    local file="$CF/$folder/$pid/$pid.cpp"
    local binary="/tmp/cf_$pid"
    local testdir="$CF/$folder/$pid/test"
    g++-14 -std=c++17 -O2 -Wall -g -fsanitize=address,undefined -o "$binary" "$file" && \
    oj t -c "$binary" -d "$testdir"
}
