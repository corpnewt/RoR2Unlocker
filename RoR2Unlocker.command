#!/usr/bin/env python
import os, shutil
import xml.etree.ElementTree as ET
from Scripts import *

class RORUnlocker:

    def __init__(self):
        self.u = utils.Utils("Risk Of Rain 2 Unlocker")
        self.user_folders = os.path.join(os.environ['SYSTEMDRIVE'] + "\\", "Program Files (x86)", "Steam", "userdata")
        self.settings_path = os.path.join("632360","remote","UserProfiles")
        self.id_list = {}
        self.xml_header = '<?xml version="1.0" encoding="utf-8"?>'
        self.characters = ["Engineer", "Huntress", "Mage", "Mercenary", "Toolbot", "Treebot"]

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
                    coin = root.find("coins").text
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

    def get_unlocks(self, xml_root):
        return [x.text[11:] for x in xml_root.iter("unlock") if x.text.lower().startswith("characters.")]

    def select_profile(self, profile):
        self.u.head("Select a Profile")
        print("")
        for x,y in enumerate(profile):
            name = self.get_name(y["root"])
            coins = self.get_coins(y["root"])
            unlocked = self.get_unlocks(y["root"])
            print("{}. {}".format(x+1,name))
            print("  --> Coins:    {:,}".format(coins))
            print("  --> Unlocked: {}".format(", ".join(unlocked) if len(unlocked) else "None"))
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
        self.u.head(name)
        print("")
        print("C. Coins:    {:,}".format(coins))
        print("U. Unlocked: {}".format(", ".join(unlocked) if len(unlocked) else "None"))
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

    def lock_character(self, profile, character):
        # We have an index - let's remove it
        found = False
        for x in profile["root"].iter("unlock"):
            if x.text.lower().startswith("characters.") and x.text.lower().endswith(character.lower()):
                # Found it - remove
                found = True
                parent = profile["root"].find("stats")
                parent.remove(x)
        return found

    def unlock_character(self, profile, character):
        # Assume we typed a new one - let's add it.  Check if it exists first
        for x in profile["root"].iter("unlock"):
            if x.text.lower().startswith("characters.") and x.text.lower().endswith(character.lower()):
                # Found it - bail
                return False
        # If we got here - we should be able to add it as a child of the stats element
        a = profile["root"].find("stats")
        b = ET.SubElement(a,"unlock")
        # Strip "Characters." from the header if it exists
        if character.lower().startswith("characters."):
            character = menu[11:]
        b.text = "Characters."+character
        return True

    def update_unlocks(self, profile):
        name = self.get_name(profile["root"])
        unlocks = self.get_unlocks(profile["root"])
        self.u.head("{}'s Unlocked Characters".format(name))
        print("")
        if len(unlocks):
            for x,y in enumerate(unlocks):
                print("{}. {}".format(x+1, y))
        else:
            print("No characters unlocked")
        print("")
        print("A. Unlock All")
        print("L. Lock All")
        print("M. Profile Menu")
        print("Q. Quit")
        print("")
        print("Type the number of the character in the above list")
        print("to re-lock them.  Or type the name of a character to")
        print("unlock them.\n")
        print("Known Unlockables:  {}\n".format(", ".join(self.characters)))
        menu = self.u.grab("Please select an option:  ")
        if not len(menu):
            return self.update_unlocks(profile)
        if menu.lower() == "m":
            return
        elif menu.lower() == "q":
            self.u.custom_quit()
        elif menu.lower() == "a":
            # Unlock all characters we know of
            found = False
            for x in self.characters:
                if self.unlock_character(profile,x):
                    found = True
            if found:
                self.save_profile(profile)
            return self.update_unlocks(profile)
        elif menu.lower() == "l":
            # Lock all characters that we've unlocked
            found = False
            for x in unlocks:
                if self.lock_character(profile,x):
                    found = True
            if found:
                self.save_profile(profile)
            return self.update_unlocks(profile)
        # Should have value - check for int within range
        try:
            menu = int(menu)-1
        except:
            pass
        if isinstance(menu,int):
            if not -1<menu<len(unlocks):
                # Assume we're out of range
                return self.update_unlocks(profile)
            # We have an index - let's remove it
            if self.lock_character(profile,unlocks[menu]):
                # Assume we removed it - let's write the file and return
                self.save_profile(profile)
        else:
            # Assume we typed a new one - let's add it.  Check if it exists first
            if self.unlock_character(profile,menu):
                self.save_profile(profile)
        return self.update_unlocks(profile)

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
                    print("  - {}".format(name))
                    print("  --> Coins:    {:,}".format(coins))
                    print("  --> Unlocked: {}".format(", ".join(unlocked) if len(unlocked) else "None"))
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
        try:
            r.main()
        except Exception as e:
            u.head("An Error Occurred")
            print("")
            print(e)
            print("")
            u.grab("Press [enter] to continue...")