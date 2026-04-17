#!/bin/bash
# Move all unsubscribe-list emails from ULB Inbox in batches of 100.
# Each sender is processed until no more emails remain.
# Safe to interrupt and re-run.

SCRIPT="$(dirname "$0")/move-batch.applescript"

declare -A SENDERS=(
    # folder=sender pairs
    ["Unsubscribe - LinkedIn"]="invitations@linkedin.com messaging-digest-noreply@linkedin.com messages-noreply@linkedin.com updates-noreply@linkedin.com notifications-noreply@linkedin.com jobs-listings@linkedin.com newsletters-noreply@linkedin.com linkedin@e.linkedin.com"
    ["Unsubscribe - Amazon"]="store-news@amazon.com promotion5@amazon.de store-news@amazon.com.be store-news@amazon.de"
    ["Unsubscribe - SSRN"]="ERN@publish.ssrn.com correspondence@communications.ssrn.com FEN@publish.ssrn.com LSN@publish.ssrn.com"
    ["Unsubscribe - Bloomberg"]="noreply@mail.bloombergview.com noreply@mail.bloombergbusiness.com noreply@news.bloomberg.com"
    ["Unsubscribe - Economist"]="newsletters@e.economist.com noreply@e.economist.com"
    ["Unsubscribe - Hessen Brussels"]="veranstaltungen@lv-bruessel.hessen.de Heike.Tiede@lv-bruessel.hessen.de"
    ["Unsubscribe - IPE"]="news@email.ipe.com events@email.ipe.com"
    ["Unsubscribe - Harvard Business"]="hbpmarketing@hbsp.harvard.edu HE@academic.hbsp.harvard.edu"
    ["Unsubscribe - FT"]="FT@newsletters.ft.com info@stories-features.ft.com"
    ["Unsubscribe - PRI"]="comms@e-marketing.unpri.org"
    ["Unsubscribe - MLex"]="press@mlex.com"
    ["Unsubscribe - Zoom"]="no-reply@zoom.us"
    ["Unsubscribe - NYT"]="nytdirect@nytimes.com"
    ["Unsubscribe - EIU"]="eiu_enquiries@eiu.com"
    ["Unsubscribe - Substack"]="paulkrugman@substack.com braddelong@substack.com"
    ["Unsubscribe - Robert Schuman"]="info@lalettre.robert-schuman.eu"
    ["Unsubscribe - FEB VBO"]="febvbo@vbo-feb.be"
    ["Unsubscribe - Netflix"]="info@mailer.netflix.com"
    ["Unsubscribe - MS Quarantine"]="quarantine@messaging.microsoft.com"
    ["Unsubscribe - Domainbox"]="support@domainbox.net wdrp-notices@domainbox.net"
    ["Unsubscribe - CRISP"]="ne-pas-repondre@crisp.be"
    ["Unsubscribe - Lufthansa"]="newsletter@your.lufthansa-group.com"
    ["Unsubscribe - INOMICS"]="inomics-alert@inomics.com"
    ["Unsubscribe - Academia"]="updates@academia-mail.com"
    ["Unsubscribe - WEF"]="intelligence@email.weforum.org"
    ["Unsubscribe - Diligent"]="dmi.press@diligent.com"
    ["Unsubscribe - United"]="MileagePlus_Partner@enews.united.com"
    ["Unsubscribe - Apple"]="News_Europe@InsideApple.Apple.com"
    ["Unsubscribe - Audible"]="info@audible.de"
    ["Unsubscribe - Davis Polk"]="dpwmailbox@davispolk.com"
    ["Unsubscribe - Lexxion"]="service@lexxion.info"
    ["Unsubscribe - ABR"]="info@academyofbusinessresearch.com"
    ["Unsubscribe - PrivCo"]="dailystack@privco.com"
    ["Unsubscribe - France Strategie"]="france-strategie@infos.france-strategie.fr"
    ["Unsubscribe - Carbon Tracker"]="sperham@carbontracker.org"
    ["Unsubscribe - Brussels Airlines"]="noreply@news.brusselsairlines.com"
)

TOTAL=0

for folder in "${!SENDERS[@]}"; do
    for addr in ${SENDERS[$folder]}; do
        while true; do
            moved=$(osascript "$SCRIPT" "$addr" "$folder" 2>/dev/null)
            if [ -z "$moved" ] || [ "$moved" = "0" ]; then
                break
            fi
            TOTAL=$((TOTAL + moved))
            echo "  $addr → $folder: $moved (total: $TOTAL)"
        done
    done
    echo "✓ $folder done"
done

echo ""
echo "=== Total moved: $TOTAL ==="
