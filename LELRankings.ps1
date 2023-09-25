$random = Get-Random
$tourneys = Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"} "https://raw.githubusercontent.com/cmcaul03/LELRanks/main/current-tourney?raw=true&rand=$random"
$tourneys = $tourneys.content
$download_name = "AOE4World_Dump"
$current_path = split-path -parent $MyInvocation.MyCommand.Definition
$current_path="D:\GIT\LELRanks\"
$profileid_csv = import-csv "D:\GIT\LELRanks\profile-ids.csv"

$Time = Get-Date

git pull ($current_path)

$FolderName = "$current_path\web\"
if (Test-Path $FolderName) {
}
else
{
    New-Item $FolderName -ItemType Directory
}



$dumps = Invoke-RestMethod https://aoe4world.com/api/v0/data_dumps
$dump = $dumps | Where-Object {$_.key -eq "leadersboards/rm_1v1/elo"}
if ((Get-Date $dump.updated_at) -lt (Get-Date).AddDays(-3)) {
    $gz = Invoke-RestMethod $dump.url -OutFile "$current_path\$download_name.gz"
    C:\'Program Files'\7-Zip\7z.exe x "$current_path\$download_name.gz" -y
}
$csv = import-csv "$current_path\rm_1v1_0.csv"

$csv_date = Get-ChildItem -Path "$current_path\rm_1v1_0.csv" | select CreationTime

$csv_date = $csv_date.CreationTime

    Foreach ($tourney in $tourneys -split "`n") {

    # echo "tourney is: $tourney" }

    if ($tourney -ne "") {

    $tourney = $tourney.ToString()

    $tourney = $tourney -replace "`t|`n|`r",""
    $tourney = $tourney -replace " ;|; ",";"

    $players_response = Invoke-RestMethod "https://api.start.gg/tournament/$tourney`?expand[]=entrants"



    $players = $players_response.entities.entrants

    $lel_team_data = @()
    $twc_team_data = @()
    $other_team_data = @()

    $event_response = Invoke-RestMethod "https://api.smash.gg/tournament/$tourney`?expand[]=event"

    $group_response = Invoke-RestMethod "https://api.smash.gg/tournament/$tourney`?expand[]=groups"

    $events = $event_response.entities.event

    if ($events[0].endAt -lt ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds)) {
        $current_tourney_number = [int]($tourney -replace '\D+(\d+)','$1')
        $next_tourney =  "rising-empires-weeklies-"+($current_tourney_number+1)
        Set-Content -Path "D:\GIT\LELRanks\current-tourney" -Value $next_tourney
    }

    $groups = $group_response.entities.groups

    $total_players = $players_response.entities.entrants.Count

    $brackets = $null
    $bracket_players = $null

    Foreach ($event in $events) {
    $slug = $event.slug
        $bracket_response =  Invoke-RestMethod "https://api.smash.gg/$slug`?expand[]=brackets"
        $brackets += $bracket_response.entities.phase
        $bracket_players += $bracket_response.entities.standings
    }

    $entrantlist = @()

    Foreach ($group in $groups) {
        $groupId = $group.id
        $phaseId = $group.phaseId
        $entrants = Invoke-RestMethod "https://api.smash.gg/phase_group/$groupId`?expand[]=entrants"
        Foreach ($entrant in $entrants.entities.entrants) {
            $entrant | Add-Member -MemberType NoteProperty -Name "GroupId" -Value $phaseId -Force
            $entrantlist += $entrant
        }    
    }


    Foreach ($player_ob in $players) {

        $profileId = $null

        Foreach($event in $events) {
            if ($player_ob.eventId -match $event.id) {
                $event_name = $event.name
                $event_slug = $event.slug
            }
        }        

        $player_phaseId = $null

        Foreach($entrant in $entrantlist) {
            if ($entrant.id -match $player_ob.id) {
                $player_phaseId = $entrant.groupId
            }
        }


        $player_bracket_name = $null

        Foreach($bracket in $brackets) {
            if ($bracket.id -match $player_phaseId) {
                $player_bracket_name = $bracket.name
            }
        }

        $attendee_id = $player_ob.id

        $player = $player_ob.name
        $player_original = $player_ob.name
        

        if ($player -eq "Moketronics") {
            $player = "Moketronics7740"
        }elseif ($player -eq "OmnissiahMaster") {
            $player = "OmnissiaH"
            $profileId = "10481437"
        }elseif ($player -eq "eulenberg") {
            $player = "Jimmy Neutron"
            $profileId = "6970118"
        }elseif ($player -eq "Racoondog") {
            $player = "Feigi"
            $profileId = "1464301"
        }elseif ($player -eq "Obiwankevinobi") {
            $player = "What r u doing step gamer ??"
            $profileId = "12176996"
        }elseif ($player -eq "21Capable") {
            $player = "¢αραbℓє"
            $profileId = "1628773"
        }elseif ($player -eq "OMG | FoX D i E") {
            $player = "FoX D i E"
            $profileId = "1145293"
        }elseif ($player -eq "Taha24 | KobeDoge") {
            $player = "Taha24"
            $profileId = "1007570"
        }elseif ($player -eq "GT | mjerticla") {
            $player = "GT_Mjerticla"
            $profileId = "6600634"
        }elseif ($player -eq "KingSmurf") {
            $player = "[R.E.] KingSmurf"
            $profileId = "8010816"
        }elseif ($player -eq "Enesbg4") {
            $player = "Poise TB-2"
            $profileId = "12111572"
        }elseif ($player -eq "CaptainTank") {
            $player = "Captain Tank"
            $profileId = "6522555"
        }elseif ($player -eq "Vito | Lord Vito On Drugs") {
            $player = "danxz"
            $profileId = "11466432"
        }elseif ($player -eq "fenix") {
            $profileId = "11020395"
        }elseif ($player -eq "Daywalker") {
            $player = "DayWalker7617"
        }elseif ($player -eq "miked1991") {
            $player = "	miked"
            $profileId = "1531382"
        }elseif ($player -eq "Combi | _ChIvO__") {
            $player = "Combi | _ChIvO__"
            $profileId = "1913468"
        }elseif ($player -eq "barun511") {
            $player = "[WoP]barun511"
            $profileId = "3283060"
        }elseif ($player -eq "bruhvinash") {
            $player = "weboom6643"
            $profileId = "11464533"
        }elseif ($player -eq "Cow") {
            $profileId = "11070410"
        }elseif ($player -eq "Dindi9896") {
            $profileId = "11541652"
        }elseif ($player -eq "Extra Deep Throat") {
            $profileId = "7096362"
        }elseif ($player -eq "bingchilling") {
            $profileId = "11645430"
        }elseif ($player -eq "[Wl]_freecapsack") {
            $player = "Rise of Patience"
        }elseif ($player -eq "Cynique" -or $player -eq "El Cyniquo") {
            $player = "El Cyniquo"
            $profileId = "4123982"
        }elseif ($player -eq "Rode") {
            $profileId = "7038867"
        }elseif ($player -eq "Free") {
            $player = "Free"
            $profileId = "3696245"
        }elseif ($player -eq "everlast") {
            $player = "everlast007"
        }elseif ($player -eq "DEAC-Hackers | KosdaBence") {
            $player = "KosdaBence"
        }elseif ($player -eq "frij | FRIJ00") {
            $player = "_FRIJ00"
        }elseif ($player -eq "Rizzler7 | Rizzler7") {
            $player = "Rizzler7"
        }elseif ($player -eq "MTP | unknoowbody") {
            $player = "unknoowbody"
        }elseif ($player -eq "EZ | MID") {
            $player = "MID"
            $profileId = "8216671"
        }elseif ($player -eq "RDK") {
            $profileId = "3781236"
        }elseif ($player -eq "Xoai") {
            $player = "Xoài"
        }elseif ($player -eq "Justin") {
            $player = "Justin"
            $profileId = "1760517"
        }elseif ($player -eq "Imperator") {
            $player = "Imperator"
            $profileId = "6665286"
        }elseif ($player -eq "Maximus") {
            $player = "Maximus"
            $profileId = "2518513"
        }elseif ($player -eq "Domc") {
            $player = "Domc"
            $profileId = "6652373" 
        }elseif ($player -eq "Le Grand Mugul") {
            $player = "Le Grand Mugul"
            $profileId = "4927615"
        }elseif ($player -eq "Rakka") {
            $player = "Rakka1371"
            $profileId = "8893108"
        }elseif ($player -eq "Rakka") {
            $player = "Rakka1371"
            $profileId = "8893108"
        }elseif ($player -eq "ThatBoyNathaN7") {
            $profileId = "7043450"
        }elseif ($player -eq "Armit4ge2433") {
            $profileId = "9278415"
        }elseif ($player -eq "PSR | Draldrin") {
            $player = "PSR.Draldrin"
            $profileId = "1155996"
        }elseif ($player -eq "CarterSC2") {
            $player = "Carter"
            $profileId = "9200788"
        }elseif ($player -eq "wololocubed") {
            $player = "WOLOLOWOLOLOWOLOLO"
            $profileId = "7829844"
        }elseif ($player -eq "Protz_btz") {
            $player = "Protz."
            $profileId = "7700516"
        }elseif ($player -eq "Papa | Timewhiledrunk") {
            $player = "Timewhiledrunk"
            $profileId = "7080000"
        }elseif ($player -eq "Adne") {
            $player = "[Holy] Adne"
            $profileId = "1220994"
        }elseif ($player -eq "nytwish") {
            $player = "nутwiѕн.nутraid ㄨ"
            $profileId = "10515622"
        }elseif ($player -eq "HASTILES | cholioli874") {
            $player = "cholioli874"
            $profileId = "6694715"
        }elseif ($player -eq "voro | eukaliptal") {
            $player = "eukaliptal"
            $profileId = "7765282"
        }elseif ($player -eq "AAM07 | ApolloMaster07") {
            $player = "ApolloMaster07"
            $profileId = "3639483"
        }elseif ($player -eq "Jessieadams") {
            $player = "Ineedsheep"
            $profileId = "8781592"
        }elseif ($player -eq "Zoro | Zoro no Senpai") {
            $player = "Zoro no Senpai"
            $profileId = "6955697"
        }elseif ($player -eq "Mountian Dew | XxTrickShotxX") {
            $player = "Mr.BlueSky"
            $profileId = "1752510"
        }elseif ($player -eq "Dragora") {
            $player = "Mystic"
            $profileId = "262647"
        }elseif ($player -eq "[Real] | aNi_11") {
            $player = "[Real] aNi_11"
            $profileId = "369057"
        }elseif ($player -eq "Dezkar") {
            $player = "Dezkar6927"
            $profileId = "5912643"
        }elseif ($player -eq "WayofSix") {
            $player = "[ODB] WayofSix"
            $profileId = "674431"
        }elseif ($player -eq "Trakor") {
            $player = "PSR.Trakor"
            $profileId = "1712108"
        }elseif ($player -eq "Shineko") {
            $player = "[NW] NakanoMikuSimp❤"
            $profileId = "10400991"
        }elseif ($player -eq "ingsok") {
            $player = "ingsoc8106"
            $profileId = "7625747"
        }elseif ($player -eq "CoRe") {
            $player = "CoRe"
            $profileId = "7090781"
        }elseif ($player -eq "KobeDoge") {
            $player = "Taha24"
            $profileId = "1007570"
        }elseif ($player -eq "Hell") {
            $player = "Hell"
            $profileId = "8391512"
        }elseif ($player -eq "Vendetta Gaming | dualitycsgo") {
            $player = "Duality"
            $profileId = "10463340"
        }elseif ($player -eq "ochrey") {
            $player = "Ragefroggy"
            $profileId = "8370445"
        }elseif ($player -eq "Anubis") {
            $player = "Buzzingrapier86"
            $profileId = "9363257"
        }elseif ($player -eq "SheRmaN") {
            $player = "[E-gear] SheRmaN"
            $profileId = "9093868"
        }elseif ($player -eq "SheRmaN") {
            $profileId = "10955184"
        }elseif ($player -eq "COINNU (aka PSiArc)") {
            $player = "COINNU"
            $profileId = "6967276"
        }elseif ($player -eq "Twinkie757") {
            $player = "Twinkie7571042"
            $profileId = "7606794"
        }elseif ($player -eq "Seb") {
            $player = "Seb"
            $profileId = "1043916"
        }elseif ($player -eq "The Butcher") {
            $player = "TheButcher"
            $profileId = "8376753"
        }elseif ($player -eq "Seb") {
            $player = "Seb"
            $profileId = "1043916"
        }elseif ($player -eq "Seb") {
            $player = "Seb"
            $profileId = "1043916"
        }elseif ($player -eq "iNcog") {
            $player = "iNcoGG"
            $profileId = "11264344"
        }elseif ($player -eq "Hustler") {
            $player = "Hustl3r1606"
            $profileId = "7508502"
        }elseif ($player -eq "[E-gear]Arabskiy_TIGER") {
            $player = "TIGER"
            $profileId = "8269666"
        }elseif ($player -eq "Hustler") {
            $player = "Hustl3r1606"
            $profileId = "7508502"
        }elseif ($player -eq "bwhit | mindless dribble") {
            $player = "mindless dribble"
            $profileId = "7437888"
        }elseif ($player -eq "Buzzingrapier86 | Anubis") {
            $player = "BuzzingRapier86"
            $profileId = "9363257"
        }elseif ($player -eq "Rise of Patience") {
            $player = "[CIT] Rise of Daddy"
            $profileId = "301858"
        }elseif ($player -eq "Crackedy") {
            $player = "CrackedyHere"
            $profileId = "230361"
        }elseif ($player -eq "[LASAGNE] | Le Garf") {
            $player = "Garfield'sGapingGulper"
            $profileId = "6103016"
        }elseif ($player -eq "Hustler") {
            $player = "Hustl3r1606"
            $profileId = "7508502"
        }elseif ($player -eq "Hustler") {
            $player = "Hustl3r1606"
            $profileId = "7508502"
        }elseif ($player -eq "N/A | Fury Road") {
            $player = "FuryRoad"
            $profileId = "10724618"
        }elseif ($player -eq "Boo") {
            $player = "NerdyZen"
            $profileId = "9908462"
        }elseif ($player -eq "SkWizZ | CarterSC2") {
            $player = "SkWizZ_Carter"
            $profileId = "9200788"
        }elseif ($player -eq "NyC | jRemix") {
            $player = "Yo my guy"
            $profileId = "230548"
        }elseif ($player -eq "felipemkp") {
            $player = "fmkp"
            $profileId = "3368992"
        }elseif ($player -eq "Mkoll") {
            $player = "𝕄𝕜𝕠𝕝𝕝"
            $profileId = "76561198048952014"
        }elseif ($player -eq "Pokemonuniteplayer") {
            $player = "Easy Ai(bot)"
            $profileId = "7140821"
        }elseif ($player -eq "Phanatic") {
            $player = "Phanatic"
            $profileId = "73290"
        }elseif ($player -eq "KingGeo07") {
            $player = "SnapShot"
            $profileId = "4617596"
        }elseif ($player -eq "felipemkp") {
            $player = "fmkp"
            $profileId = "3368992"
        }elseif ($player -eq "felipemkp") {
            $player = "fmkp"
            $profileId = "3368992"
        }elseif ($player -eq "TheRemiG") {
            $profileId = "2235803"
        }elseif ($player -eq "TheRemiG") {
            $profileId = "2235803"
        }

        if ($player -match "\|") {
            $player = ($player.Split(" | "))
            $player = $player[($player.Length-1)]
        }

        if ($profileid_csv -match $player) {
            $profileId = ($profileid_csv | Where-Object {$_.player -Match "^$player$"}).profile_id | select-object -Last 1
        }

        $response = ""

        $response = Invoke-RestMethod "https://aoe4world.com/api/v0/players/search?query=$player"

        Foreach ($response_ind in $response.players) {
            if ($response_ind.Name -eq $player -and $profileId -eq $null) {
                $profileId = $response_ind.profile_id
                $response = $response_ind
            }
        }

        $count = $response.players.Count

        if ($count -eq 1 -or $profileId -ne $null) {
             if ($profileId -eq $null) {
                 $profileId = $response.players[0].profile_id
             }
             $response = Invoke-RestMethod "https://aoe4world.com/api/v0/players/$profileId"
        }

        $player = $player.ToString()
    
        $player_object = New-Object PSObject
        $player_object | Add-Member -MemberType NoteProperty -Name "AOE Name" -Value $player -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Start GG Name" -Value "<a href=`"https://www.start.gg/$event_slug/entrant/$attendee_id`">$player_original</a>" -Force
    

        if($response.modes.rm_1v1 -ne $null) {
            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Elo" -Value $response.modes.rm_1v1.rating -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value $response.modes.rm_1v1.rank -Force}
        elseif ($count -gt 1 -and $profileId -eq $null) {
            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Elo" -Value "There was $count matches for the string $player" -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value "There was $count matches"  -Force
        }
        else {
            
            #$response = Invoke-RestMethod "https://aoeiv.net/api/leaderboard?game=aoe4&event_leaderboard_id=1&start=1&count=10&profile_id=$profileId"

            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Elo" -Value $response.leaderboard[0].rating -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value $response.leaderboard[0].rank -Force

            if ($player_object.'Ladder Elo' -eq $null) {

            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Elo" -Value "There was $count matches for the string $player" -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value "There was $count matches"  -Force}
        }


        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")

        $body = "{`"region`": `"7`",`"versus`": `"players`",`"matchType`": `"ranked`",`"teamSize`": `"1v1`",`"searchPlayer`": `"$player`",`"page`": 1,`"count`": 100}"

        $response2 = ""

        $response2 = Invoke-RestMethod 'https://api.ageofempires.com/api/ageiv/Leaderboard' -Method 'POST' -Headers $headers -Body $body

        $player = $player.ToString()

        $count2 = $response2.items.Count

        $test = 1

        Foreach ($object in $response2.items) {
            if ($object.rlUserId -eq $profileId) {
                $response2 = $object
                $test = 0
            }
        }


        if ($count2 -eq 1 -and $profileId -eq $null) {
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value $response2.items[0].elo -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value $response2.items[0].rank -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value ($response2.items[0].wins + $response2.items[0].losses) -Force
            $response_test2 = $response2.items[0].elo
        } elseif ($response2.elo -ne $null) {
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value $response2.elo -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value $response2.rank -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value ($response2.wins + $response2.losses) -Force
        } elseif ($csv -match $profileId) {
            $player_csv_object = $csv | Where-Object {$_.profile_id -Match $profileId}
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value ($player_csv_object.rating) -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value $player_csv_object.rank -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value $player_csv_object.games_count -Force
        } elseif ($csv -match $player) {
            $player_csv_object = $csv | Where-Object {$_.Name -Match $player}
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value ($player_csv_object.rating) -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value $player_csv_object.rank -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value $player_csv_object.games_count -Force
        }  else {
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value "There was $count2 matches for the string $player" -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value "There was $count2 matches" -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value "There was $count2 matches" -Force
        } 

        if ($response2.elo -eq $null -and $response_test2 -eq $null -and $player_csv_object -eq $null) {
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value "There was $count2 matches for the string $player" -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value "There was $count2 matches" -Force
            $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value "There was $count2 matches" -Force    
        }

        if ($profileId){
            $player_object | Add-Member -MemberType NoteProperty -Name "AOE Name" -Value "<a href=`"https://aoe4world.com/players/$profileId`">$player</a>" -Force
        } elseif ($response.profile_id){
            $profile_id = $response.profile_id
            $player_object | Add-Member -MemberType NoteProperty -Name "AOE Name" -Value "<a href=`"https://aoe4world.com/players/$profile_id`">$player</a>" -Force
        } elseif ($response.data.profile_id) {
            $profile_id = $response.data.profile_id
            $player_object | Add-Member -MemberType NoteProperty -Name "AOE Name" -Value "<a href=`"https://aoe4world.com/players/$profile_id`">$player</a>" -Force
        } elseif ($profileId) {
            $player_object | Add-Member -MemberType NoteProperty -Name "AOE Name" -Value "<a href=`"https://aoe4world.com/players/$profileId`">$player</a>" -Force
        } elseif ($response2.items[0].rlUserId) {
            $profile_id = $response2.items[0].rlUserId
            $player_object | Add-Member -MemberType NoteProperty -Name "AOE Name" -Value "<a href=`"https://aoe4world.com/players/$profile_id`">$player</a>" -Force
        } elseif ($response2.rlUserId) {
            $profile_id = $response2.rlUserId
            $player_object | Add-Member -MemberType NoteProperty -Name "AOE Name" -Value "<a href=`"https://aoe4world.com/players/$profile_id`">$player</a>" -Force
        }

        $player_object | Add-Member -MemberType NoteProperty -Name "Bracket" -Value $player_bracket_name -Force

        $player_object.'Hidden Elo' = [int]($player_object.'Hidden Elo')
        $player_object 

        $event_link = "<a href=`"https://www.start.gg/$event_slug`">$event_name</a>"

        $player_object | Add-Member -MemberType NoteProperty -Name "Registered For" -Value $event_link -Force

        if ($player_object.'Registered For' -like "*The Warchief Club*") {
            $twc_team_data += $player_object
            $twc_total_players=$twc_total_players +1
        } elseif ($player_object.'Registered For' -like "*Low Elo Legends*") {
            $lel_team_data += $player_object
            $lel_total_players=$lel_total_players +1
        } else {
            $other_team_data += $player_object
            $other_total_players=$other_total_players +1
        }
    }
    
    $Time = Get-Date
    $Time = $Time.ToUniversalTime()

    $head = @"
    <style>
    table {
        border-collapse: collapse;
        margin: 25px 0;
        font-size: 0.9em;
        font-family: sans-serif;
        min-width: 400px;
        box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
        width: 80%;
        padding-left: 10%;
        margin-left: 10%;
    }

    p {
        border-collapse: collapse;
        margin: 25px 0;
        font-size: 0.9em;
        font-family: sans-serif;
        padding-left: 10%;
    }


    tbody tr th {
        background-color: #009879;
        color: #ffffff;
        text-align: left;
    }

    th,
    td {
        padding: 12px 15px;
    }

    tbody tr {
        border-bottom: 1px solid #dddddd;
    }

    tbody tr:nth-of-type(even) {
        background-color: #f3f3f3;
    }

    tbody tr:last-of-type {
        border-bottom: 2px solid #009879;
    }
    </style>
    <p>Last updated at: $time UTC. <a href="https://cmcaul03.github.io/LELRanks/">Shit Menu</a>
"@

Add-Type -AssemblyName System.Web

        if ($tourney -like "*rising-empires*") {
                $lel_html = $lel_team_data | Sort-Object -Property 'Hidden Elo' -Descending| ConvertTo-Html "AOE Name","Start GG Name","Ladder Elo","Ladder Rank","Hidden Elo","Hidden Rank","Games Played","Registered For" -Head ($head + " There were $lel_total_players players found. </p>")
                [System.Web.HttpUtility]::HtmlDecode($lel_html) |  Out-File "$current_path\web\LEL-$tourney.html"
                $lel_team_data | Sort-Object -Property "Hidden Rank", "Bracket" | Export-CSV  "$current_path\web\LEL-$tourney.csv" -NoTypeInformation

                $twc_html = $twc_team_data | Sort-Object -Property "Registered For", "Hidden Rank", "Bracket" | ConvertTo-Html "AOE Name","Start GG Name","Ladder Elo","Ladder Rank","Hidden Elo","Hidden Rank","Games Played","Registered For", "Bracket" -Head ($head + " There were $twc_total_players players found. </p>")
                [System.Web.HttpUtility]::HtmlDecode($twc_html) |  Out-File "$current_path\web\TWC-$tourney.html"
                $twc_team_data | Sort-Object -Property "Hidden Rank", "Bracket" | Export-CSV  "$current_path\web\TWC-$tourney.csv" -NoTypeInformation
        } else {
                $other_html = $other_team_data | Sort-Object -Property "Registered For", "Hidden Rank", "Bracket" | ConvertTo-Html "AOE Name","Start GG Name","Ladder Elo","Ladder Rank","Hidden Elo","Hidden Rank","Games Played","Registered For", "Bracket" -Head ($head + " There were $other_total_players players found. </p>")
                [System.Web.HttpUtility]::HtmlDecode($other_html) |  Out-File "$current_path\web\OTHER-$tourney.html"
        }
    }
}


powershell.exe "$current_path\GenerateMenu.ps1"