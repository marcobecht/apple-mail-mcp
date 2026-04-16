-- Create Apple Mail rules to auto-move future emails from
-- unsubscribe-list senders to "Unsubscribe - X" folders in ULB.
-- Generated 2026-04-16.
--
-- Each rule uses "any condition" matching so multiple sender
-- addresses route to the same folder.

on createRule(ruleName, senderList)
    tell application "Mail"
        -- Delete existing rule with same name if any
        try
            delete rule ruleName
        end try

        set ulbAcct to first account whose name is "ULB"

        -- Create or get destination folder
        try
            set destBox to mailbox ruleName of ulbAcct
        on error
            make new mailbox with properties {name:ruleName} at ulbAcct
            delay 1
            set destBox to mailbox ruleName of ulbAcct
        end try

        -- Create rule: any condition matches -> move to folder
        set newRule to make new rule at end of rules with properties {name:ruleName, all conditions must be met:false, move message:destBox}

        tell newRule
            repeat with addr in senderList
                make new rule condition at end of rule conditions with properties {rule type:from header, qualifier:does contain value, expression:addr}
            end repeat
        end tell

        set enabled of newRule to true
        return (count of senderList) as text
    end tell
end createRule

on run
    set total to 0

    set total to total + createRule("Unsubscribe - LinkedIn", {"invitations@linkedin.com", "messaging-digest-noreply@linkedin.com", "messages-noreply@linkedin.com", "updates-noreply@linkedin.com", "notifications-noreply@linkedin.com", "jobs-listings@linkedin.com", "newsletters-noreply@linkedin.com", "linkedin@e.linkedin.com"})
    log "LinkedIn rule created"

    set total to total + createRule("Unsubscribe - Amazon", {"store-news@amazon.com", "promotion5@amazon.de", "store-news@amazon.com.be", "store-news@amazon.de"})
    log "Amazon rule created"

    set total to total + createRule("Unsubscribe - SSRN", {"ERN@publish.ssrn.com", "correspondence@communications.ssrn.com", "FEN@publish.ssrn.com", "LSN@publish.ssrn.com"})
    log "SSRN rule created"

    set total to total + createRule("Unsubscribe - Bloomberg", {"noreply@mail.bloombergview.com", "noreply@mail.bloombergbusiness.com", "noreply@news.bloomberg.com"})
    log "Bloomberg rule created"

    set total to total + createRule("Unsubscribe - Economist", {"newsletters@e.economist.com", "noreply@e.economist.com"})
    log "Economist rule created"

    set total to total + createRule("Unsubscribe - Hessen Brussels", {"veranstaltungen@lv-bruessel.hessen.de", "Heike.Tiede@lv-bruessel.hessen.de"})
    log "Hessen rule created"

    set total to total + createRule("Unsubscribe - IPE", {"news@email.ipe.com", "events@email.ipe.com"})
    log "IPE rule created"

    set total to total + createRule("Unsubscribe - Harvard Business", {"hbpmarketing@hbsp.harvard.edu", "HE@academic.hbsp.harvard.edu"})
    log "HBP rule created"

    set total to total + createRule("Unsubscribe - FT", {"FT@newsletters.ft.com", "info@stories-features.ft.com"})
    log "FT rule created"

    set total to total + createRule("Unsubscribe - PRI", {"comms@e-marketing.unpri.org"})
    set total to total + createRule("Unsubscribe - MLex", {"press@mlex.com"})
    set total to total + createRule("Unsubscribe - Zoom", {"no-reply@zoom.us"})
    set total to total + createRule("Unsubscribe - NYT", {"nytdirect@nytimes.com"})
    set total to total + createRule("Unsubscribe - EIU", {"eiu_enquiries@eiu.com"})
    set total to total + createRule("Unsubscribe - Substack", {"paulkrugman@substack.com", "braddelong@substack.com"})
    set total to total + createRule("Unsubscribe - Robert Schuman", {"info@lalettre.robert-schuman.eu"})
    set total to total + createRule("Unsubscribe - FEB VBO", {"febvbo@vbo-feb.be"})
    set total to total + createRule("Unsubscribe - Netflix", {"info@mailer.netflix.com"})
    set total to total + createRule("Unsubscribe - MS Quarantine", {"quarantine@messaging.microsoft.com"})
    set total to total + createRule("Unsubscribe - Domainbox", {"support@domainbox.net", "wdrp-notices@domainbox.net"})
    set total to total + createRule("Unsubscribe - CRISP", {"ne-pas-repondre@crisp.be"})
    set total to total + createRule("Unsubscribe - Lufthansa", {"newsletter@your.lufthansa-group.com"})
    set total to total + createRule("Unsubscribe - INOMICS", {"inomics-alert@inomics.com"})
    set total to total + createRule("Unsubscribe - Academia", {"updates@academia-mail.com"})
    set total to total + createRule("Unsubscribe - WEF", {"intelligence@email.weforum.org"})
    set total to total + createRule("Unsubscribe - Diligent", {"dmi.press@diligent.com"})
    set total to total + createRule("Unsubscribe - United", {"MileagePlus_Partner@enews.united.com"})
    set total to total + createRule("Unsubscribe - Apple", {"News_Europe@InsideApple.Apple.com"})
    set total to total + createRule("Unsubscribe - Audible", {"info@audible.de"})
    set total to total + createRule("Unsubscribe - Davis Polk", {"dpwmailbox@davispolk.com"})
    set total to total + createRule("Unsubscribe - Lexxion", {"service@lexxion.info"})
    set total to total + createRule("Unsubscribe - ABR", {"info@academyofbusinessresearch.com"})
    set total to total + createRule("Unsubscribe - PrivCo", {"dailystack@privco.com"})
    set total to total + createRule("Unsubscribe - France Strategie", {"france-strategie@infos.france-strategie.fr"})
    set total to total + createRule("Unsubscribe - Carbon Tracker", {"sperham@carbontracker.org"})
    set total to total + createRule("Unsubscribe - Brussels Airlines", {"noreply@news.brusselsairlines.com"})
    log "All individual rules created"

    return "Created rules covering " & total & " sender addresses"
end run
