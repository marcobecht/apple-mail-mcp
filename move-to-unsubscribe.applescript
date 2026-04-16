-- Move ULB Inbox newsletters to "Unsubscribe - <category>" folders
-- for review before deletion and unsubscribing.
-- Generated 2026-04-16.

on moveSenderToFolder(senderMatch, folderName)
    tell application "Mail"
        set ulbAcct to first account whose name is "ULB"
        set inboxBox to mailbox "Inbox" of ulbAcct

        -- Create folder if it doesn't exist
        try
            set destBox to mailbox folderName of ulbAcct
        on error
            make new mailbox with properties {name:folderName} at ulbAcct
            delay 1
            set destBox to mailbox folderName of ulbAcct
        end try

        set msgs to (every message of inboxBox whose sender contains senderMatch)
        set msgCount to count of msgs

        if msgCount > 0 then
            repeat with msg in msgs
                move msg to destBox
            end repeat
        end if

        return msgCount
    end tell
end moveSenderToFolder

on run
    set totalMoved to 0
    set results to {}

    -- LinkedIn
    set totalMoved to totalMoved + moveSenderToFolder("invitations@linkedin.com", "Unsubscribe - LinkedIn")
    set totalMoved to totalMoved + moveSenderToFolder("messaging-digest-noreply@linkedin.com", "Unsubscribe - LinkedIn")
    set totalMoved to totalMoved + moveSenderToFolder("messages-noreply@linkedin.com", "Unsubscribe - LinkedIn")
    set totalMoved to totalMoved + moveSenderToFolder("updates-noreply@linkedin.com", "Unsubscribe - LinkedIn")
    set totalMoved to totalMoved + moveSenderToFolder("notifications-noreply@linkedin.com", "Unsubscribe - LinkedIn")
    set totalMoved to totalMoved + moveSenderToFolder("jobs-listings@linkedin.com", "Unsubscribe - LinkedIn")
    set totalMoved to totalMoved + moveSenderToFolder("newsletters-noreply@linkedin.com", "Unsubscribe - LinkedIn")
    set totalMoved to totalMoved + moveSenderToFolder("linkedin@e.linkedin.com", "Unsubscribe - LinkedIn")
    log "LinkedIn done, total so far: " & totalMoved

    -- Amazon
    set totalMoved to totalMoved + moveSenderToFolder("store-news@amazon.com", "Unsubscribe - Amazon")
    set totalMoved to totalMoved + moveSenderToFolder("promotion5@amazon.de", "Unsubscribe - Amazon")
    set totalMoved to totalMoved + moveSenderToFolder("store-news@amazon.com.be", "Unsubscribe - Amazon")
    set totalMoved to totalMoved + moveSenderToFolder("store-news@amazon.de", "Unsubscribe - Amazon")
    log "Amazon done, total so far: " & totalMoved

    -- SSRN
    set totalMoved to totalMoved + moveSenderToFolder("ERN@publish.ssrn.com", "Unsubscribe - SSRN")
    set totalMoved to totalMoved + moveSenderToFolder("correspondence@communications.ssrn.com", "Unsubscribe - SSRN")
    set totalMoved to totalMoved + moveSenderToFolder("FEN@publish.ssrn.com", "Unsubscribe - SSRN")
    set totalMoved to totalMoved + moveSenderToFolder("LSN@publish.ssrn.com", "Unsubscribe - SSRN")
    log "SSRN done, total so far: " & totalMoved

    -- Bloomberg
    set totalMoved to totalMoved + moveSenderToFolder("noreply@mail.bloombergview.com", "Unsubscribe - Bloomberg")
    set totalMoved to totalMoved + moveSenderToFolder("noreply@mail.bloombergbusiness.com", "Unsubscribe - Bloomberg")
    set totalMoved to totalMoved + moveSenderToFolder("noreply@news.bloomberg.com", "Unsubscribe - Bloomberg")
    log "Bloomberg done, total so far: " & totalMoved

    -- Economist
    set totalMoved to totalMoved + moveSenderToFolder("newsletters@e.economist.com", "Unsubscribe - Economist")
    set totalMoved to totalMoved + moveSenderToFolder("noreply@e.economist.com", "Unsubscribe - Economist")
    log "Economist done, total so far: " & totalMoved

    -- Hessen Brussels
    set totalMoved to totalMoved + moveSenderToFolder("veranstaltungen@lv-bruessel.hessen.de", "Unsubscribe - Hessen Brussels")
    set totalMoved to totalMoved + moveSenderToFolder("Heike.Tiede@lv-bruessel.hessen.de", "Unsubscribe - Hessen Brussels")
    log "Hessen done, total so far: " & totalMoved

    -- IPE
    set totalMoved to totalMoved + moveSenderToFolder("news@email.ipe.com", "Unsubscribe - IPE")
    set totalMoved to totalMoved + moveSenderToFolder("events@email.ipe.com", "Unsubscribe - IPE")
    log "IPE done, total so far: " & totalMoved

    -- Harvard Business Publishing
    set totalMoved to totalMoved + moveSenderToFolder("hbpmarketing@hbsp.harvard.edu", "Unsubscribe - Harvard Business")
    set totalMoved to totalMoved + moveSenderToFolder("HE@academic.hbsp.harvard.edu", "Unsubscribe - Harvard Business")
    log "HBP done, total so far: " & totalMoved

    -- Financial Times
    set totalMoved to totalMoved + moveSenderToFolder("FT@newsletters.ft.com", "Unsubscribe - FT")
    set totalMoved to totalMoved + moveSenderToFolder("info@stories-features.ft.com", "Unsubscribe - FT")
    log "FT done, total so far: " & totalMoved

    -- Individual senders (one folder each)
    set totalMoved to totalMoved + moveSenderToFolder("comms@e-marketing.unpri.org", "Unsubscribe - PRI")
    set totalMoved to totalMoved + moveSenderToFolder("press@mlex.com", "Unsubscribe - MLex")
    set totalMoved to totalMoved + moveSenderToFolder("no-reply@zoom.us", "Unsubscribe - Zoom")
    set totalMoved to totalMoved + moveSenderToFolder("nytdirect@nytimes.com", "Unsubscribe - NYT")
    set totalMoved to totalMoved + moveSenderToFolder("eiu_enquiries@eiu.com", "Unsubscribe - EIU")
    set totalMoved to totalMoved + moveSenderToFolder("paulkrugman@substack.com", "Unsubscribe - Substack")
    set totalMoved to totalMoved + moveSenderToFolder("braddelong@substack.com", "Unsubscribe - Substack")
    set totalMoved to totalMoved + moveSenderToFolder("info@lalettre.robert-schuman.eu", "Unsubscribe - Robert Schuman")
    set totalMoved to totalMoved + moveSenderToFolder("febvbo@vbo-feb.be", "Unsubscribe - FEB VBO")
    set totalMoved to totalMoved + moveSenderToFolder("info@mailer.netflix.com", "Unsubscribe - Netflix")
    set totalMoved to totalMoved + moveSenderToFolder("quarantine@messaging.microsoft.com", "Unsubscribe - MS Quarantine")
    set totalMoved to totalMoved + moveSenderToFolder("support@domainbox.net", "Unsubscribe - Domainbox")
    set totalMoved to totalMoved + moveSenderToFolder("wdrp-notices@domainbox.net", "Unsubscribe - Domainbox")
    set totalMoved to totalMoved + moveSenderToFolder("ne-pas-repondre@crisp.be", "Unsubscribe - CRISP")
    set totalMoved to totalMoved + moveSenderToFolder("newsletter@your.lufthansa-group.com", "Unsubscribe - Lufthansa")
    set totalMoved to totalMoved + moveSenderToFolder("inomics-alert@inomics.com", "Unsubscribe - INOMICS")
    set totalMoved to totalMoved + moveSenderToFolder("updates@academia-mail.com", "Unsubscribe - Academia")
    set totalMoved to totalMoved + moveSenderToFolder("intelligence@email.weforum.org", "Unsubscribe - WEF")
    set totalMoved to totalMoved + moveSenderToFolder("dmi.press@diligent.com", "Unsubscribe - Diligent")
    set totalMoved to totalMoved + moveSenderToFolder("MileagePlus_Partner@enews.united.com", "Unsubscribe - United")
    set totalMoved to totalMoved + moveSenderToFolder("News_Europe@InsideApple.Apple.com", "Unsubscribe - Apple")
    set totalMoved to totalMoved + moveSenderToFolder("info@audible.de", "Unsubscribe - Audible")
    set totalMoved to totalMoved + moveSenderToFolder("dpwmailbox@davispolk.com", "Unsubscribe - Davis Polk")
    set totalMoved to totalMoved + moveSenderToFolder("service@lexxion.info", "Unsubscribe - Lexxion")
    set totalMoved to totalMoved + moveSenderToFolder("info@academyofbusinessresearch.com", "Unsubscribe - ABR")
    set totalMoved to totalMoved + moveSenderToFolder("dailystack@privco.com", "Unsubscribe - PrivCo")
    set totalMoved to totalMoved + moveSenderToFolder("france-strategie@infos.france-strategie.fr", "Unsubscribe - France Strategie")
    set totalMoved to totalMoved + moveSenderToFolder("sperham@carbontracker.org", "Unsubscribe - Carbon Tracker")
    set totalMoved to totalMoved + moveSenderToFolder("noreply@news.brusselsairlines.com", "Unsubscribe - Brussels Airlines")

    log "All done. Total moved: " & totalMoved
    return "Total moved: " & totalMoved
end run
