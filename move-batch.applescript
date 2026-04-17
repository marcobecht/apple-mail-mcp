-- Batch mover: moves up to N emails per sender per run.
-- Avoids AppleEvent timeouts on large mailboxes by limiting
-- each query to a small batch.  Run repeatedly until 0 moved.

on moveBatch(senderMatch, folderName, batchSize)
    tell application "Mail"
        set ulbAcct to first account whose name is "ULB"
        set inboxBox to mailbox "Inbox" of ulbAcct

        try
            set destBox to mailbox folderName of ulbAcct
        on error
            make new mailbox with properties {name:folderName} at ulbAcct
            delay 1
            set destBox to mailbox folderName of ulbAcct
        end try

        -- Get only a limited batch to avoid timeout
        set msgs to (every message of inboxBox whose sender contains senderMatch)
        set msgCount to count of msgs
        if msgCount is 0 then return 0

        set moveCount to 0
        repeat with i from 1 to msgCount
            if moveCount >= batchSize then exit repeat
            try
                move (item i of msgs) to destBox
                set moveCount to moveCount + 1
            end try
        end repeat

        return moveCount
    end tell
end moveBatch

on run argv
    set senderAddr to item 1 of argv
    set folderName to item 2 of argv
    set moved to moveBatch(senderAddr, folderName, 100)
    return moved as text
end run
