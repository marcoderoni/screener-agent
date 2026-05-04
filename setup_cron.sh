#!/bin/bash
# =============================================================
#  setup_cron.sh
#  Adds a weekly cron job: every Friday at 18:00 local time
#  Logs output to /tmp/screener.log
# =============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/screener.py"
PYTHON_PATH="$(which python3)"
LOG_PATH="/tmp/screener_agent.log"

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "❌  screener.py not found at $SCRIPT_PATH"
  exit 1
fi

CRON_JOB="0 18 * * 5 cd $SCRIPT_DIR && $PYTHON_PATH $SCRIPT_PATH >> $LOG_PATH 2>&1"

# Add job only if not already present
( crontab -l 2>/dev/null | grep -v "screener.py"; echo "$CRON_JOB" ) | crontab -

echo "✅  Cron job added:"
echo "    Schedule : every Friday at 18:00"
echo "    Command  : $PYTHON_PATH $SCRIPT_PATH"
echo "    Log      : $LOG_PATH"
echo ""
echo "To verify:  crontab -l"
echo "To remove:  crontab -e  (delete the screener line)"
