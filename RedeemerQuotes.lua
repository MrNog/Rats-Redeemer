--Unattributed quotes are assumed to come from me.

--If you want to add your own quotes, make sure to
--format them correctly:
--1. Quotes must be surrounded by double quotes(")
--2. The closing quote must be followed by a comma(,)
--3. Sections must begin and end with curly braces( { } )
--4. Notes must be prefixed with a double hyphen( -- )
--5. There must not be any extraneous characters
--Failure to comply with any of the above will cause Redeemer to break.

--To insert the target's name in a quote, use "%t".

--genericQuotes is just the fallback pool (rarely used now -- every rez
--type below has its own themed list). A few strong RATS lines as a net.
em

--Priest -- Resurrection
priestQuotes = {

	"Prayed back from the dead, %t. Don't waste it, colleague.",
	"Rise, %t. The RATS aren't done with this boss.",

}

--Shaman -- Ancestral Spirit
shamanQuotes = {

	"The ancestors aren't done with you, %t. Rise, colleague.",
	"Up, %t! Even the spirits won't let a rat rest.",

}

--Druid -- Revive (out of combat)
druidQuotes = {

	"Nature reclaims you, %t -- back to the pack, colleague.",
	"Up, %t! The sewers grow their rats right back.",

}

--Hunter -- Revive Pet (%t is the pet's name)
hunterQuotes = {

	"Up, %t! Even a rat's hound doesn't quit.",
	"On your paws, %t -- the pack needs its beast.",

}

--Combat -- Rebirth (battle rez, mid-fight)
combatQuotes = {

	"No time to die, %t -- we're mid-fight, colleague!",
	"Battle-rezzed, %t! Up, the boss still breathes!",
	"Up, %t! Only the rats who refuse to stay down become the Warchief's Fangs.",
	"Rise, %t! Crawl up from the dead and maybe you'll earn your Fangs.",
	"Up, %t! Every Fang of the Warchief was once a rat who wouldn't die.",

}

--Engineer -- Defibrillate (jumper cables)
engineerQuotes = {

	"*ZAP* Back you go, %t. Filthy rat tech, baby.",
	"Cables to the chest, %t -- try not to explode.",

}

--Death Knight -- Raise Dead (ghoul minion; %t may be empty)
deathKnightDeadQuotes = {

	"Rise, servant of the Scourge -- claw for the rats!",
	"A fresh ghoul crawls out of the sewer. Sic 'em.",

}

--Death Knight -- Raise Ally (battle rez)
deathKnightAllyQuotes = {

	"The Scourge spits you back out, %t. Fight, colleague!",
	"Frost couldn't keep you, %t -- up and bite!",

}

--Warlock -- Soulstone Resurrection
warlockQuotes = {

	"Your soul was on layaway, %t. Collect it and fight.",
	"Up, %t! Worth more than cheese, that soul of yours.",

}

--Self -- own Soulstone self-rez (no %t; you are the target)
selfQuotes = {

	"A sewer rat always has an exit. Back from the dead, colleagues.",
	"Death is for other people. For the Horde, colleagues!",

}
