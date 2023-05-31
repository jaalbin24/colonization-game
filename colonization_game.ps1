#================================================================================
#  This is a game called Colonization wherein the player controls a ship navigating
#  through space to find a planet to colonize.
#  
#  Team member names:
#    Jeremy Albin - Lead Developer
#    Brian Willis - Assistant to the Lead Developer
#    Kain Sparks - Consultant
#    Will Flowers - Development QA
#
#  
#  
#================================================================================





# Used to convert an integer to a string ordinal. For example, 1 => '1st'
function ConvertToOrdinal([int]$number) {
    if ($number -lt 0) {
        throw "Number must be a positive integer."
    }

    $suffix = 'th'
    $lastDigit = $number % 10
    $lastTwoDigits = $number % 100

    if ($lastTwoDigits -lt 11 -or $lastTwoDigits -gt 13) {
        switch ($lastDigit) {
            1 { $suffix = 'st' }
            2 { $suffix = 'nd' }
            3 { $suffix = 'rd' }
        }
    }
    return "$number$suffix"
}

# Takes an array as input and returns a random value from that array
function Get-RandomValueFromArray($array) {
    if ($array.Count -le 0) {
        return
    }
    $randomIndex = Get-Random -Minimum 0 -Maximum $array.Count
    return $array[$randomIndex]
}
# Takes an integer (n) and an array and removes the first and last nth elements
# This function is used for determining planet ratings with upgraded scanners
function RemoveLastNElements($n, $arr) {
    if ($n -ge $arr.Count) {
        return @()
    }

    $newArr = $arr[0..($arr.Count - $n - 1)]
    return $newArr
}

class Game {
    static [Planet] $currentPlanet
    static [Ship] $ship = [Ship]::new()
    static [boolean] $colonized = 0
    static start() {
        Clear-host
        #User input to customize experience - Willis
	$name = Read-Host "What is your Name?"

        Write-host "Greetings Captain $Name, Welcome to the UNSC Forward unto Dawn"
        #Intro Narrative - Willis
        Write-host "We have 100 colonists and are preparing to embark forward on one of Mankind's greatest adventures.  We are setting sail into the stars to develop new colonies for earth."

        [Encounter]::InitEncounters()
        Write-host "   _____      _             _          _   _            
  / ____|    | |           (_)        | | (_)            
 | |     ___ | | ___  _ __  _ ______ _| |_ _  ___  _ __  
 | |    / _ \| |/ _ \| '_ \| |_  / _` | __| |/ _ \| '_ \
 | |___| (_) | | (_) | | | | |/ / (_| | |_| | (_) | | | |
  \_____\___/|_|\___/|_| |_|_/___\__,_|\__|_|\___/|_| |_|
                                                         
                                                         "
        Write-host "`n==================== WELCOME ======================"
        Write-host "`nYou are aboard a state-of-the-art starship on a historical mission. Set in a future where humanity has vanished from Earth, the fate of the last remnants of our species rests solely in your virtual hands."
        Write-host "`nYou are entrusted with the daunting task of scouring the vast expanse of space to seek out a new home for the colonists aboard your starship. These brave souls are the last surviving humans, floating through the void, their hopes clinging to your guidance and expertise."
        Write-host "`nEquipped with a sub-light speed starship, you travel the void for millenia, visiting various planets in search of the perfect candidate for colonization. Will you find a hospitable and bountiful planet that can sustain life?"
        Write-host "`nPress enter to begin..."
        Read-host
        while ([Game]::colonized -eq 0) {
            [Menu]::ArriveAndScan()
            [Menu]::ScanResults()
            if ([Game]::colonized -eq 0) {
                [Menu]::UpgradeOpportunity()
                [Menu]::UpgradeResults()
                [Menu]::EncounterOpportunity()
            } else {
                [Menu]::Colonization()
            }
        }
    }
}

class Menu {
    static ShipStatus() {
        Clear-host
        Write-host "`n================= SHIP DIAGNOSTICS =================="
        $table = [Game]::ship.Scanners| Select Name, Level | Format-Table -AutoSize | Out-String
        Write-host $table
        Write-host "$([Game]::ship.colonists) colonists are still alive onboard.`n`n"
    }
    static ArriveAndScan() {
        [Menu]::ShipStatus()
        Write-host "============== YOU HAVE FOUND A PLANET ==============`n"
        Write-host "$([Menu]::ArriveAndScanMessage())"
        Write-host "`nPress enter to scan the planet..."
        Read-host
    }
    static ScanResults() {
        [Menu]::ShipStatus()
        $planet = [Planet]::new()
        Write-host "==================== SCAN RESULTS ===================`n"
        Write-host "The data slowly comes back from your scanners. You wait anxiously until, at last, the report is finally ready."
        $table = $planet.Ratings | Format-Table -AutoSize | Out-String
        Write-host $table
        Write-host "What do you want to do?"
        Write-host "1) Colonize this planet"
        Write-host "2) Try to find a better home"
        $choice = Read-host "`nEnter a number"
        if ($choice -eq '1') {
            [Game]::colonized = 1
        }
    }
    static Colonization() {
        Clear-host
        Write-host "`n=================== PLANET COLONIZED ===================`n"
        Write-host "
                                                      _._
                                                  ,o88888
                                               ,o8888888'
                         ,:o:o:oooo.        ,8O88Pd8888'
                     ,.::.::o:ooooOoOoO. ,oO8O8Pd888'
                   ,.:.::o:ooOoOoOO8O8OOo.8OOPd8O8O'
                  , ..:.::o:ooOoOOOO8OOOOo.FdO8O8'
                 , ..:.::o:ooOoOO8O888O8O,COCOO'
                , . ..:.::o:ooOoOOOO8OOOOCOCO'
                 . ..:.::o:ooOoOoOO8O8OCCCC/o
                    . ..:.::o:ooooOoCoCCC/o:o
                    . ..:.::o:o:,cooooCo/oo:o:
                 `   . . ..:.:cocoooo/'o:o:::'
                 .`   . ..::ccccoc/'o:o:o:::'
                :.:.    ,c:cccc/':.:.:.:.:.'
              ..:.:;'`::::c:/'..:.:.:.:.:.'
            ...:.'.:.::::/'    . . . . .'
           .. . ....:./' `   .  . . ''
         . . . ..../'
         .. . ./'     -hrr-
        ."
        Write-host "`n`n`nYou finally found a planet for humanity to call home.`nThe ship touches down, and the colonists wake from their hibernation chambers to explore their new world.`n`n`n`n`n`n`n`n`n"
       if ([Game]::CurrentPlanet.Habitability() -le 25) {
         Write-host "This planet is extremely inhospitable though. The young colony cannot cope and quickly succumbs to the hazardous environment."
       } elseif([Game]::CurrentPlanet.Habitability() -le 50) {
       	 Write-host "This planet is rather inhospitable though. The young colony is tenacious, but eventually succumbs to the hazardous envrionment."
       } elseif([Game]::CurrentPlanet.Habitability() -le 75) {
         Write-host "This planet is almost comfortable. It is not as hospitable as Earth was, but it will sustain the colony."
       } else {
         Write-host "This planet is a new paradise. Our colonists will be happy here."
       }
    }
    static UpgradeOpportunity() {
        [Menu]::ShipStatus()
        Write-host "================ UPGRADE OPPORTUNITY ================`n"
        Write-host "You have learned a lot from traveling the stars. You can choose to upgrade one of your scanners to help you detect higher quality planets from a distance."
        Write-host "`nWhich scanner would you like to upgrade?"        
        #For Function - Flowers
	for ($i = 0; $i -lt [Game]::ship.Scanners.Count; $i++) {
            $scanner = [Game]::ship.Scanners[$i]
            Write-Host "$($i + 1)) $($scanner.Name)"
        }
        $upgradeChoice = Read-host "`nEnter a number"
        #Switch Function -Willis
	switch($upgradeChoice) {
            1 {[Game]::ship.WaterScanner.Upgrade()}
            2 {[Game]::ship.AtmosphereScanner.Upgrade()}
            3 {[Game]::ship.GravityScanner.Upgrade()}
            4 {[Game]::ship.TemperatureScanner.Upgrade()}
            5 {[Game]::ship.ResourceScanner.Upgrade()}
        }
    }
    static UpgradeResults() {
        [Menu]::ShipStatus()
        Write-host "================= SCANNER UPGRADED ==================`n"
        Write-host "You upgraded your scanner! This will help you find higher quality planets more often."
        Write-host "`nPress enter to return to your hibernation pod and continue your journey..."
        Read-host
    }
    static [string] ArriveAndScanMessage() {
        $message = "You travel for hundreds of years through deep space. All that is left of humanity is within your ship. `n`n"
        $message += "Your ship awakens you from hibernation as you approach a stable orbit around the "
        $planet_num = Get-Random -Minimum 1 -Maximum 5
        $message += ConvertToOrdinal($planet_num)
        if ((Get-Random -Minimum 0 -Maximum 2) % 2 -eq 0) {
            $message += " planet orbiting a "
        } else {
            $message += " moon of a gas giant orbiting a "
        }
        $message += Get-RandomValueFromArray(@(
            'red dwarf',
            'yellow dwarf',
            'blue giant',
            'white dwarf',
            'neutron star',
            'red supergiant',
            'brown dwarf',
            'black hole'
        ))
        $a = Get-Random -Minimum 0 -Maximum 3
        if ($a % 3 -eq 0) {
            $message += " in a trinary star system."
        } elseif ($a % 3 -eq 1) {
            $message += " in a binary star system."
        } else {
            $message += " in a solitary star system."
        }
        $message += "`n`nYou hope this will be the perfect place to restart humanity, but you will have to scan the planet below to know for sure. "
        
        $message += "`n"
        $message += BriansMessage($planet_num)
        
        return $message
    }
    static EncounterOpportunity() {
        [Menu]::ShipStatus()
        $encounter = [Encounter]::PickRandomEncounter()
        Write-host "==================== ENCOUNTER =====================`n"
        Write-host $encounter.Context
        Write-host "`nWhat will you do?`n"
        ForEach($choice in $encounter.Choices) {
            $choice
            Write-host "$($choice.Id)) $($choice.Description)"
        }
        $exitFlag = 0
        do {
            $idChoice = Read-host "`nEnter a number"
            ForEach($choice in $encounter.Choices) {
                if($choice.Id -eq $idChoice) {
                    [Menu]::EncounterResults($choice)
                    $exitFlag = 1
                } else {
                    Write-host "That input is not valid."
                }
            }
       
        } while($exitFlag -eq 0)
    }
    static EncounterResults([Choice] $choice) {
        $choice.Execute()
        [Menu]::ShipStatus()
        Write-host $choice.Outcome
        Write-host "Press enter to continue..."
        Read-host
    }
}
class Encounter {
    static [Encounter[]] $Encounters
    [string] $Context
    [Choice[]] $Choices

    static InitEncounters() {
        [Choice[]] $choice_array = @(
            [Choice]::new(1, "Offer help", "", $false),
            [Choice]::new(2, "Move on", "You ignore their desperate pleas and continue your journey.", $true)
        )
        [Encounter]::Encounters += [Encounter]::new("As you steer the starship deeper into unexplored regions of the galaxy, you detect a distress signal originating from a nearby planet. Upon further investigation, you discover a small colony of human survivors who have been struggling to survive on this desolate world. They eagerly request assistance, as their resources are rapidly dwindling, and they lack the means to escape the planet's harsh environment.", $choice_array)
    }

    static [Encounter] PickRandomEncounter() {
        return Get-RandomValueFromArray([Encounter]::Encounters)
    }

    Encounter([string]$context, [Choice[]]$choices) {
        $this.Context = $context
        $this.Choices = $choices
    }
}
class Choice {
    [int] $Id
    [string] $Description
    [string] $Outcome

    [boolean] $NeutralOutcome

    Choice([int]$id, [string]$description, [string] $outcome, [boolean] $neutralOutcome ) {
        $this.Id = $id
        $this.Description = $description
        $this.Outcome = $outcome
        $this.NeutralOutcome = $neutralOutcome
    }
    Execute() {
        if ($this.NeutralOutcome) {
            return
        } elseif ((Get-Random) % 2 -eq 0) {
            $this.ExecuteGood()
            $this.Outcome = "You have learned from your decision and upgraded a scanner."
        } else {
            $this.ExecuteBad()
            $this.Outcome = "That decsision has caused some colonists to die."
        }
    }
    ExecuteBad() {
        [Game]::ship.colonists -= Get-Random -Minimum 5 -Maximum 20
    }

    ExecuteGood() {
        switch(Get-Random -Minimum 0 -Maximum 5) {
            1 { [Game]::ship.WaterScanner.Upgrade() }
            2 { [Game]::ship.GravityScanner.Upgrade() }
            3 { [Game]::ship.AtomsphereScanner.Upgrade() }
            4 { [Game]::ship.TemperatureScanner.Upgrade() }
            5 { [Game]::ship.ResourceScanner.Upgrade() }
        }
        #Get-RandomValueFromArray([Game]::ship.Scanners).Upgrade()
    }
}
class Planet {
    [PlanetRating[]] $Ratings
    Planet() {
        ForEach($trait in "Water", "Temperature", "Gravity", "Atmosphere", "Resources") {
            $this.Ratings += [PlanetRating]::new($trait)
        }
    }
}
class PlanetRating {
    [string] $Trait
    [string] $Rating
    static [string[]] $AtmosphereRatings = @(
        "Breathable",
        "Marginal",
        "Non-breathable",
        "Toxic",
        "Corrosive",
        "None"
    )
    static [string[]] $WaterRatings = @(
        "Oceans",
        "Ice caps",
        "Planet-wide ocean",
        "Ice-covered surface",
        "Trace",
        "None"
    )
    static [string[]] $GravityRatings = @(
        "Moderate",
        "Very high",
        "High",
        "Low",
        "Very low"
    )
    static [string[]] $TemperatureRatings = @(
        "Moderate",
        "Very hot",
        "Hot",
        "Cold",
        "Very cold"
    )
    static [string[]] $ResourceRatings = @(
        "Rich",
        "Poor",
        "None"
    )
    PlanetRating([string]$trait) {
        $this.Trait = $trait
            switch ($trait) {
            "Water" { $this.Rating = Get-RandomValueFromArray(RemoveLastNElements ([Game]::ship.WaterScanner.Level) @([PlanetRating]::WaterRatings)) }
            "Gravity" { $this.Rating = Get-RandomValueFromArray(RemoveLastNElements([Game]::ship.GravityScanner.Level) @([PlanetRating]::GravityRatings)) }
            "Atmosphere" { $this.Rating = Get-RandomValueFromArray(RemoveLastNElements([Game]::ship.AtmosphereScanner.Level) @([PlanetRating]::AtmosphereRatings)) }
            "Resources" { $this.Rating = Get-RandomValueFromArray(RemoveLastNElements([Game]::ship.ResourcesScanner.Level) @([PlanetRating]::ResourceRatings)) }
            "Temperature" { $this.Rating = Get-RandomValueFromArray(RemoveLastNElements([Game]::ship.TemperatureScanner.Level) @([PlanetRating]::TemperatureRatings)) }
            default { $this.Rating = "DEFAULT" }
        }
        "$($this.Trait): $($this.Rating)" >> "C:\Users\god\Downloads\colonization_game.txt"
    }
}


# Use a for-loop to do Xyz


class Ship {
    [ShipScanner[]] $Scanners
    [ShipScanner] $WaterScanner
    [ShipScanner] $AtmosphereScanner
    [ShipScanner] $GravityScanner
    [ShipScanner] $TemperatureScanner
    [ShipScanner] $ResourceScanner
    [int] $colonists
    Ship() {
        $this.WaterScanner = [ShipScanner]::new("Water scanner")
        $this.AtmosphereScanner = [ShipScanner]::new("Atmosphere scanner")
        $this.GravityScanner = [ShipScanner]::new("Gravity scanner")
        $this.TemperatureScanner = [ShipScanner]::new("Temperature scanner")
        $this.ResourceScanner = [ShipScanner]::new("Resource scanner")
        $this.Scanners += $this.WaterScanner
        $this.Scanners += $this.AtmosphereScanner
        $this.Scanners += $this.GravityScanner
        $this.Scanners += $this.TemperatureScanner
        $this.Scanners += $this.ResourceScanner
        $this.colonists = 100
    }
}


class ShipScanner {
    [int] $Level
    [string] $Name
    ShipScanner([string]$name) {
        $this.Name = $name
        $this.Level = 0
    }
    Upgrade() {
        $this.Level++
    }
}

# Written by Kain Sparks
function playGame {
    [string]$play = Read-Host " Do you want to play this game? Enter Yes or Y"
    if($play -eq "Yes" -or $play -eq "Y" -or $play -eq "yes" -or $play -eq "y") {
        write " Good. Enjoy your adventure!"
        continue
    }
    else
    {
        write "You're missing out on your epic adventure"
        exit
    }
}
#Planet Identification ifeslseif function with Randomizer to generate different planet names -Willis
function BriansMessage($planet_num) {
    $Planet = Random(1..20)

    if ($Planet -eq 1){$PlanetName = "Tarkin"}
    elseif ($Planet -eq 2){$PlanetName ="Obi Wan"}
    elseif ($Planet -eq 3){$PlanetName ="Wick"}
    elseif ($Planet -eq 4){$PlanetName ="Dora" }
    elseif ($Planet -eq 5){$PlanetName ="Vader" }
    elseif ($Planet -eq 6){$PlanetName ="Sisko"}
    elseif ($Planet -eq 7){$PlanetName ="Picard"}
    elseif ($Planet -eq 8){$PlanetName ="Skywalker"}
    elseif ($Planet -eq 9){$PlanetName ="Spock"}
    elseif ($Planet -eq 10){$PlanetName ="Arbiter"}
    elseif ($Planet -eq 11){$PlanetName ="Covenant"}
    elseif ($Planet -eq 12){$PlanetName ="Tantive" }
    elseif ($Planet -eq 13){$PlanetName ="Yavin"}
    elseif ($Planet -eq 14){$PlanetName ="Solo" }
    elseif ($Planet -eq 15){$PlanetName ="Tiberius"}
    elseif ($Planet -eq 16){$PlanetName ="Kirk"}
    elseif ($Planet -eq 17){$PlanetName ="Quill"}
    elseif ($Planet -eq 18){$PlanetName ="Groot"}
    elseif ($Planet -eq 19){$PlanetName ="Asgard"}
    elseif ($Planet -eq 20){$PlanetName ="New Oregon"}

    return "`nCongratulations Captain $Name, you've reached $PlanetName $planet_num"
}

# Fix to Scanner failures - if else function
function BriansFix {
    $Scanners = 0

    $Water = Random(1..20) 
    $Gravity
    $Atmosphere
    $Resources
    $Temperature

    If ($scanners + $Water -ge 15) {$OutputW = “Water is Plentiful”)
	  Elseif ($scanners +$water [5..14]) {$OutputW = “Water is Acceptable”}
          Elseif ($scanners +$water -lt 5) {$OutputW = “No Water is Present”} 
    if ($scanners +$Gravity + $scanners -gt 10) {$OutputG = “Gravity is in Acceptable Tolerance”} 
    	Elseif ($scanners +$Gravity 5..9) {$OutputG = “Gravity is Crushing”} 
    	Elseif ($scanners +$Gravity -lt 5) {$OutputG = “Gravity is too Light”} 
    if ($scanners +$Resources -gt 15) {$OutputR = “Resources are Abundant”} 
    	Elseif ($Resources +$Gravity 5..15) {$OutputR = “Resources are Sparse”} 
   	 Elseif ($Resources +$water -lt 5) {$OutputR = “No Readily Accessible Resources”} 
    if ($scanners +$Atmosphere-gt 15) {$OutputA = “Breathable Atmosphere”} 
   	 Elseif ($Atmosphere +$Gravity 5..15) {$OutputA = “Atmosphere is Thin”} 
   	 Elseif ($Atmosphere +$water -lt 5) {$OutputA = “Atmosphere is Toxic”} 
    if ($scanners +$Temperature -gt 15) {$OutputT = “Sunny and 75”} 
   	 Elseif ($scanners +$Temperature 5..15) {$OutputT = “Ice Planet”} 
   	 Elseif ($scanners +$Temperature -lt 5) {$OutputT = “Rivers of Lava are cutting through the planet”} 

    “Scanner Results:
     $OutputW
     $OutputG
     $OutputR
     $OutputA
     $OutputT


}

#$ship = [Ship]::new()
#$ship.WaterScanner.Level += 1


#Write-host (RemoveLastNElements ($ship.WaterScanner.Level) @([PlanetRating]::WaterRatings))
cls
#[Game]::start()
[Game]::ship.GravityScanner.Level = 4
Write-host "LEVEL: $([Game]::ship.GravityScanner.Level)"
for ([int] $i = 0; $i -lt 30; $i++) {
    [PlanetRating]::new("Gravity")
}
