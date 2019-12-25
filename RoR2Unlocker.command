#!/usr/bin/env python
import os, shutil
import xml.etree.ElementTree as ET
from Scripts import *

class RORUnlocker:

    def __init__(self):
        self.u = utils.Utils("Risk Of Rain 2 Unlocker")
        self.user_folders  = os.path.join(os.environ['SYSTEMDRIVE'] + "\\", "Program Files (x86)", "Steam", "userdata")
        self.settings_path = os.path.join("632360","remote","UserProfiles")
        self.id_list = {}
        self.xml_header    = '<?xml version="1.0" encoding="utf-8"?>'
        self.characters    = ["Croco", "Engineer", "Huntress", "Loader", "Mage", "Mercenary", "Toolbot", "Treebot"]
        self.items         = ["AttackSpeedOnCrit",
                                "AutoCastEquipment",
                                "BFG",
                                "Bear",
                                "BossDamageBonus",
                                "BonusGoldPackOnKill",
                                "BounceNearby",
                                "BurnNearby",
                                "Cleanse",
                                "Clover",
                                "Crowbar",
                                "DroneBackup",
                                "ElementalRings",
                                "EnergizedOnEquipmentUse",
                                "EquipmentMagazine",
                                "ExecuteLowHealthElite",
                                "ExtraLife",
                                "Firework",
                                "Gateway",
                                "GainArmor",
                                "GoldGat",
                                "HealOnCrit",
                                "Hoof",
                                "IncreaseHealing",
                                "Infusion",
                                "JumpBoost",
                                "KillEliteFrenzy",
                                "LaserTurbine",
                                "Lightning",
                                "LunarPrimaryReplacement",
                                "LunarTrinket",
                                "LunarUtilityReplacement",
                                "Medkit",
                                "Meteor",
                                "NovaOnHeal",
                                "NovaOnLowHealth",
                                "PassiveHealing",
                                "Pearl",
                                "ProtectionPotion",
                                "RegenOnKill",
                                "RepeatHeal",
                                "Scanner",
                                "SecondarySkillMagazine",
                                "ShinyPearl",
                                "ShockNearby",
                                "Talisman",
                                "Thorns",
                                "Tonic",
                                "TreasureCache",
                                "WarCryOnMultiKill"]
        self.skills        = ["Commando.FireShotgunBlast",
                                "Commando.ThrowGrenade",
                                "Croco.ChainableLeap",
                                "Engi.WalkerTurret",
                                "Engi.SpiderMine",
                                "Huntress.MiniBlink",
                                "Huntress.Snipe",
                                "Loader.ZapFist",
                                "Loader.YankHook",
                                "Mage.FlyUp",
                                "Mage.IceBomb",
                                "Mage.LightningBolt",
                                "Merc.EvisProjectile",
                                "Merc.Uppercut",
                                "Toolbot.Grenade",
                                "Toolbot.Buzzsaw",
                                "Treebot.PlantSonicBoom",
                                "Treebot.Barrage"]
        self.skins         = ["Commando.Alt1",
                                "Croco.Alt1",
                                "Huntress.Alt1",
                                "Loader.Alt1",
                                "Mage.Alt1",
                                "Merc.Alt1",
                                "Toolbot.Alt1",
                                "Treebot.Alt1"]
        self.achievements  = ["AttackSpeed",
                                "BeatArena",
                                "BurnToDeath",
                                "CarryLunarItems",
                                "ChargeTeleporterWhileNearDeath",
                                "CommandoClearGameMonsoon",
                                "CommandoKillOverloadingWorm",
                                "CommandoNonLunarEndurance",
                                "Complete20Stages",
                                "Complete30StagesCareer",
                                "CompleteMultiBossShrine",
                                "CompletePrismaticTrial",
                                "CompleteTeleporter",
                                "CompleteTeleporterWithoutInjury",
                                "CompleteThreeStages",
                                "CompleteThreeStagesWithoutHealing",
                                "CompleteUnknownEnding",
                                "CrocoClearGameMonsoon",
                                "CrocoTotalInfectionsMilestone",
                                "DefeatSuperRoboBallBoss",
                                "Die5Times",
                                "Discover10UniqueTier1",
                                "Discover5Equipment",
                                "EngiArmy",
                                "EngiKillBossQuick",
                                "FailShrineChance",
                                "FindDevilAltar",
                                "FindTimedChest",
                                "FindUniqueNewtStatues",
                                "FreeMage",
                                "HardEliteBossKill",
                                "HardHitter",
                                "HuntressClearGameMonsoon",
                                "HuntressCollectCrowbars",
                                "HuntressMaintainFullHealthOnFrozenWall",
                                "KillBossQuantityInRun",
                                "KillBossQuick",
                                "KillElementalLemurians",
                                "KillEliteMonster",
                                "KillElitesMilestone",
                                "KillGoldTitanInOneCycle",
                                "KillTotalEnemies",
                                "LoaderBigSlam",
                                "LoaderClearGameMonsoon",
                                "LoaderSpeedRun",
                                "LogCollector",
                                "LoopOnce",
                                "MageAirborneMultiKill",
                                "MageClearGameMonsoon",
                                "MageFastBoss",
                                "MageMultiKill",
                                "MajorMultikill",
                                "MaxHealingShrine",
                                "MercClearGameMonsoon",
                                "MercCompleteTrialWithFullHealth",
                                "MercDontTouchGround",
                                "MoveSpeed",
                                "MultiCombatShrine",
                                "RepeatFirstTeleporter",
                                "RepeatedlyDuplicateItems",
                                "RescueTreebot",
                                "StayAlive1",
                                "SuicideHermitCrabs",
                                "ToolbotClearGameMonsoon",
                                "ToolbotGuardTeleporter",
                                "ToolbotKillImpBossWithBfg",
                                "TotalDronesRepaired",
                                "TotalMoneyCollected",
                                "TreebotClearGameMonsoon",
                                "TreebotDunkClayBoss",
                                "TreebotLowHealthTeleporter",
                                "UseThreePortals"]

    def check_folders(self):
        self.id_list = {}
        if not os.path.exists(self.user_folders):
            return self.id_list
        for x in os.listdir(self.user_folders):
            # Check for our game path
            temp = os.path.join(self.user_folders,x,self.settings_path)
            if os.path.exists(temp):
                # Let's load the xml and try to get the name
                for y in os.listdir(temp):
                    if y.startswith(".") or not y.lower().endswith(".xml"):
                        continue
                    # We should have a valid xml file - try to load it
                    xml = ET.parse(os.path.join(temp,y))
                    root = xml.getroot()
                    name = root.find("name").text
                    # coin = root.find("coins").text
                    if not x in self.id_list:
                        self.id_list[x] = []
                    self.id_list[x].append({
                        "id":x,
                        "file":y,
                        "xml":xml,
                        "root":root
                        })
        return self.id_list

    def save_profile(self, profile):
        # Ensure we have a backup first
        target_file = os.path.join(self.user_folders,profile["id"],self.settings_path,profile["file"])
        backup_file = os.path.join(self.user_folders,profile["id"],self.settings_path,profile["file"]+".bak")
        if not os.path.exists(backup_file):
            shutil.copyfile(target_file,backup_file)
        output_xml = ET.tostring(profile["root"],encoding="unicode")
        with open(target_file,"w") as f:
            f.write(self.xml_header+output_xml)

    def get_coins(self, xml_root):
        try:
            return int(xml_root.find("coins").text)
        except:
            return 0
    
    def get_name(self, xml_root):
        return xml_root.find("name").text

    def get_unlocks(self, xml_root, prefix="Characters."):
        return [x.text[len(prefix):] for x in xml_root.iter("unlock") if x.text.lower().startswith(prefix.lower())]

    def get_achievements(self, xml_root):
        achievements = xml_root.find("achievementsList").text
        return [] if achievements is None else achievements.split()

    def select_profile(self, profile):
        self.u.head("Select a Profile")
        print("")
        for x,y in enumerate(profile):
            name = self.get_name(y["root"])
            coins = self.get_coins(y["root"])
            unlocked = self.get_unlocks(y["root"])
            skills = self.get_unlocks(y["root"],prefix="Skills.")
            skins = self.get_unlocks(y["root"],prefix="Skins.")
            items = self.get_unlocks(y["root"],prefix="Items.")
            achievements = self.get_achievements(y["root"])
            print("{}. {}".format(x+1,name))
            print("  --> Coins:    {:,}".format(coins))
            print("  --> Characters: {}".format(", ".join(unlocked) if len(unlocked) else "None"))
            print("  --> Skills: {}".format(", ".join(skills) if len(skills) else "None"))
            print("  --> Skins: {}".format(", ".join(skins) if len(skins) else "None"))
            print("  --> Items: {}".format(", ".join(items) if len(items) else "None"))
            print("  --> Achievements: {:,} of {:,} known unlocked ({:,} total).".format(len([x for x in achievements if x in self.achievements]),len(self.achievements),len(achievements)))
        print("")
        print("M. Return to Menu")
        print("Q. Quit")
        print("")
        menu = self.u.grab("Please select an option:  ").lower()
        if not len(menu):
            return self.select_profile(profile)
        if menu == "m":
            return
        if menu == "q":
            self.u.custom_quit()
        try:
            menu = int(menu)-1
        except:
            return self.select_profile(profile)
        if not -1<menu<len(profile):
            return self.select_profile(profile)
        # Got one
        self.edit_profile(profile[menu])

    def edit_profile(self, profile):
        name = self.get_name(profile["root"])
        coins = self.get_coins(profile["root"])
        unlocked = self.get_unlocks(profile["root"])
        skills = self.get_unlocks(profile["root"],prefix="Skills.")
        skins = self.get_unlocks(profile["root"],prefix="Skins.")
        items = self.get_unlocks(profile["root"],prefix="Items.")
        achievements = self.get_achievements(profile["root"])
        self.u.head(name)
        print("")
        print("C. Coins:    {:,}".format(coins))
        print("U. Characters: {}".format(", ".join(unlocked) if len(unlocked) else "None"))
        print("S. Skills: {}".format(", ".join(skills) if len(skills) else "None"))
        print("K. Skins: {}".format(", ".join(skins) if len(skins) else "None"))
        print("I. Items: {}".format(", ".join(items) if len(items) else "None"))
        print("A. Achievements: {:,} of {:,} known unlocked ({:,} total).".format(len([x for x in achievements if x in self.achievements]),len(self.achievements),len(achievements)))
        print("")
        print("M. Main Menu")
        print("Q. Quit")
        print("")
        menu = self.u.grab("Please select an option to modify:  ").lower()
        if not len(menu):
            return self.edit_profile(profile)
        if menu == "m":
            return
        elif menu == "q":
            self.u.custom_quit()
        elif menu == "c":
            self.update_coins(profile)
        elif menu == "u":
            self.update_unlocks(profile)
        elif menu == "a":
            self.update_achievements(profile)
        elif menu == "s":
            self.update_unlocks(profile,"Skills",self.skills)
        elif menu == "k":
            self.update_unlocks(profile,"Skins",self.skins)
        elif menu == "i":
            self.update_unlocks(profile,"Items",self.items)
        self.edit_profile(profile)

    def update_coins(self, profile):
        name = self.get_name(profile["root"])
        coins = self.get_coins(profile["root"])
        self.u.head("{}'s Coins".format(name))
        print("")
        print("Currently {:,} coin{}.".format(coins, "" if coins == 1 else "s"))
        print("")
        print("M. Profile Menu")
        print("Q. Quit")
        print("")
        menu = self.u.grab("Please type the new coin amount:  ").lower()
        if not len(menu):
            return self.update_coins(profile)
        if menu == "m":
            return
        if menu == "q":
            self.u.custom_quit()
        # Should have a coin amount
        try:
            menu = int(menu)
        except:
            return self.update_coins(profile)
        # Got an int - set it
        coins = profile["root"].find("coins")
        coins.text = str(menu)
        # Let's make sure we have a totalCollectedCoins value that is > 0
        collected_coins = profile["root"].find("totalCollectedCoins")
        # Set it to the number of coins we have
        collected_coins.text = str(menu)
        self.save_profile(profile)
        return self.update_coins(profile)

    def set_achievements(self, profile, achievements):
        achievements_string = " " + " ".join(achievements) if len(achievements) else ""
        a = profile["root"].find("achievementsList")
        a.text = " ".join(achievements) # achievements_string

    def update_achievements(self, profile):
        name = self.get_name(profile["root"])
        achievements = self.get_achievements(profile["root"])
        self.u.head("{}'s Achievements".format(name))
        print("")
        print("Currently {:,} of {:,} known unlocked ({:,} total):".format(len([x for x in achievements if x in self.achievements]),len(self.achievements),len(achievements)))
        print("")
        if not len(achievements):
            print("None.")
        else:
            for x,y in enumerate(achievements):
                print("{}. {}".format(str(x+1).rjust(len(str(len(achievements)))),y))
        print("")
        print("A. Unlock All {:,} Known".format(len(self.achievements)))
        print("L. Lock All (Will remove ALL achievements - known or not)")
        print("M. Profile Menu")
        print("S. Show All Known")
        print("Q. Quit")
        print("")
        print("Type the number of the achievement in the above list")
        print("to re-lock it.  Or type the name of an achievement to")
        print("unlock it.\n")
        menu = self.u.grab("Please select an option:  ")
        if not len(menu):
            return self.update_achievements(profile)
        if menu.lower() == "m":
            return
        elif menu.lower() == "q":
            self.u.custom_quit()
        elif menu.lower() == "a":
            updated = False
            for x in self.achievements:
                if x in achievements: continue
                updated = True
                achievements.append(x)
            if updated:
                self.set_achievements(profile, achievements)
                self.save_profile(profile)
            return self.update_achievements(profile)
        elif menu.lower() == "l":
            achievements = []
            self.set_achievements(profile, achievements)
            self.save_profile(profile)
            return self.update_achievements(profile)
        elif menu.lower() == "s":
            self.u.head("All {:,} Known Achievements".format(len(self.achievements)))
            print("")
            for x,y in enumerate(self.achievements):
                print("{}. {}".format(str(x+1).rjust(len(str(len(self.achievements)))),y))
            print("")
            self.u.grab("Press [enter] to return...")
            return self.update_achievements(profile)
        try:
            menu = int(menu)-1
        except:
            pass
        if isinstance(menu,int):
            if not -1<menu<len(achievements):
                # Assume we're out of range
                return self.update_achievements(profile)
            # We have an index - let's remove it
            achievements.remove(achievements[menu])
            self.set_achievements(profile, achievements)
            self.save_profile(profile)
        else:
            # Assume we're adding a custom achievement here
            if not menu in achievements:
                achievements.append(menu)
                self.set_achievements(profile, achievements)
                self.save_profile(profile)
        return self.update_achievements(profile)

    def _lock(self, profile, element, prefix="Characters."):
        # We have an index - let's remove it
        found = False
        for x in profile["root"].iter("unlock"):
            if x.text.lower().startswith(prefix.lower()) and x.text.lower().endswith(element.lower()):
                # Found it - remove
                found = True
                parent = profile["root"].find("stats")
                parent.remove(x)
        return found

    def _unlock(self, profile, element, prefix="Characters."):
        # Assume we typed a new one - let's add it.  Check if it exists first
        for x in profile["root"].iter("unlock"):
            if x.text.lower().startswith(prefix.lower()) and x.text.lower().endswith(element.lower()):
                # Found it - bail
                return False
        # If we got here - we should be able to add it as a child of the stats element
        a = profile["root"].find("stats")
        b = ET.SubElement(a,"unlock")
        # Strip prefix from the header if it exists
        if element.lower().startswith(prefix.lower()):
            element = menu[len(prefix):]
        b.text = prefix+element
        return True

    def update_unlocks(self, profile, prefix="Characters", local_list=None):
        local_list = local_list if local_list else self.characters
        name = self.get_name(profile["root"])
        unlocks = self.get_unlocks(profile["root"],prefix=prefix+".")
        self.u.head("{}'s Unlocked {}".format(name, prefix))
        print("")
        if len(unlocks):
            for x,y in enumerate(unlocks):
                print("{}. {}".format(str(x+1).rjust(len(str(len(unlocks)))),y))
        else:
            print("No {} unlocked".format(prefix.lower()))
        print("")
        print("A. Unlock All")
        print("L. Lock All")
        print("M. Profile Menu")
        print("Q. Quit")
        print("")
        print("Type the number of the item in the above list")
        print("to re-lock them.  Or type the name of a item to")
        print("unlock them.\n")
        print("Known Unlockables:  {}\n".format(", ".join(local_list)))
        menu = self.u.grab("Please select an option:  ")
        if not len(menu):
            return self.update_unlocks(profile, prefix, local_list)
        if menu.lower() == "m":
            return
        elif menu.lower() == "q":
            self.u.custom_quit()
        elif menu.lower() == "a":
            # Unlock all items we know of
            found = False
            for x in local_list:
                if self._unlock(profile,x,prefix=prefix+"."):
                    found = True
            if found:
                self.save_profile(profile)
            return self.update_unlocks(profile, prefix, local_list)
        elif menu.lower() == "l":
            # Lock all items that we've unlocked
            found = False
            for x in unlocks:
                if self._lock(profile,x,prefix=prefix+"."):
                    found = True
            if found:
                self.save_profile(profile)
            return self.update_unlocks(profile, prefix, local_list)
        # Should have value - check for int within range
        try:
            menu = int(menu)-1
        except:
            pass
        if isinstance(menu,int):
            if not -1<menu<len(unlocks):
                # Assume we're out of range
                return self.update_unlocks(profile, prefix, local_list)
            # We have an index - let's remove it
            if self._lock(profile,unlocks[menu],prefix=prefix+"."):
                # Assume we removed it - let's write the file and return
                self.save_profile(profile)
        else:
            # Assume we typed a new one - let's add it.  Check if it exists first
            if self._unlock(profile,menu,prefix=prefix+"."):
                self.save_profile(profile)
        return self.update_unlocks(profile, prefix, local_list)

    def main(self):
        if not len(self.id_list):
            self.u.head("Checking Local Folders")
            print("")
            print("Scanning for Risk of Rain 2 user profiles...")
            self.check_folders()
        self.u.head()
        print("")
        if not len(self.id_list):
            print("No profiles found!")
        else:
            for x,y in enumerate(sorted(self.id_list)):
                print("{}. {} ({} profile{})".format(x+1,y,len(self.id_list[y]),"" if len(self.id_list[y]) == 1 else "s"))
                for a,z in enumerate(self.id_list[y]):
                    name = self.get_name(z["root"])
                    coins = self.get_coins(z["root"])
                    unlocked = self.get_unlocks(z["root"])
                    skills = self.get_unlocks(z["root"],prefix="Skills.")
                    skins = self.get_unlocks(z["root"],prefix="Skins.")
                    items = self.get_unlocks(z["root"],prefix="Items.")
                    achievements = self.get_achievements(z["root"])
                    print("  - {}".format(name))
                    print("  --> Coins:    {:,}".format(coins))
                    print("  --> Characters: {}".format(", ".join(unlocked) if len(unlocked) else "None"))
                    print("  --> Skills: {}".format(", ".join(skills) if len(skills) else "None"))
                    print("  --> Skins: {}".format(", ".join(skins) if len(skins) else "None"))
                    print("  --> Items: {}".format(", ".join(items) if len(items) else "None"))
                    print("  --> Achievements: {:,} of {:,} known unlocked ({:,} total).".format(len([x for x in achievements if x in self.achievements]),len(self.achievements),len(achievements)))
        print("")
        print("Q. Quit")
        print("")
        menu = self.u.grab("Please select a profile to edit:  ").lower()
        if not len(menu):
            return
        if menu == "q":
            self.u.custom_quit()
        # Assume it's a number
        try:
            menu = int(menu)-1
        except:
            return
        if not -1<menu<len(self.id_list):
            # Out of range
            return
        # Have one here
        profile = self.id_list[sorted(self.id_list)[menu]]
        if len(profile) == 1:
            # Only one profile there - edit it normally
            self.edit_profile(profile[0])
        else:
            # We need to select which one
            self.select_profile(profile)

if __name__ == '__main__':
    r = RORUnlocker()
    u = utils.Utils()
    while True:
        r.main()
        continue
        try:
            r.main()
        except Exception as e:
            u.head("An Error Occurred")
            print("")
            print(e)
            print("")
            u.grab("Press [enter] to continue...")
