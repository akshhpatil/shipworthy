Before executing this command, output:
> ⚓ **shipworthy** › command: `/retro` — extracting session learnings

---

Run a retrospective on the current session.

Analyze this entire conversation and extract what can be learned to make the next session better.

## Process

Invoke the `retrospective` skill and follow its full process:

1. **Extract signals** from this conversation:
   - Corrections the user made ("no", "not that", "I meant...")
   - Work that was redone or changed approach mid-stream
   - Steps that were improvised (not in any plan or skill)
   - Things that worked perfectly on first try
   - Which Shipworthy skills fired and helped
   - Which situations had no relevant skill (skill gaps)
   - User preferences discovered through their feedback

2. **Map each signal** to the relevant Shipworthy skill (or note the gap)

3. **Present a findings table** for the user to review:
   - Each finding with type, description, proposed action
   - User approves/rejects each item

4. **Apply approved changes**:
   - Save project learnings to `.shipworthy/learnings/`
   - Propose (but don't auto-apply) skill file updates
   - Suggest auto-memory entries for user-level preferences

5. **Update the session summary** with retrospective results

## Important

- Only analyze what already happened — don't suggest new work
- Be specific: "User corrected database choice from SQLite to PostgreSQL" not "There were some database discussions"
- If nothing notable happened (quick fix session), say so: "Clean session, no learnings to capture"
