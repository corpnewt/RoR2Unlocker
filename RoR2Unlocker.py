import sys, os, json, shutil
import xml.etree.ElementTree as ET
try:
    import Tkinter as tk
    import ttk
    import tkFileDialog as fd
    import tkMessageBox as mb
except:
    import tkinter as tk
    import tkinter.ttk as ttk
    from tkinter import filedialog as fd
    from tkinter import messagebox as mb

class RORUnlock:

    def __init__(self):
        self.tk = tk.Tk()
        self.tk.resizable(False, False)
        self.user_folders  = os.path.join(os.environ['SYSTEMDRIVE'] + "\\", "Program Files (x86)", "Steam", "userdata")
        self.settings_path = os.path.join("632360","remote","UserProfiles")
        self.id_list = self.check_folders()
        self.current_id = None
        self.current_profile = None
        self.current_character = None
        self.xml_header = '<?xml version="1.0" encoding="utf-8"?>'
        self.json_file = "ror2data.json"
        self.logo = "ror2logo.gif"
        self.scripts = "Scripts"
        self.data = {}
        self.logo_img = None
        # Let's load the data if found
        cwd = os.getcwd()
        os.chdir(os.path.dirname(os.path.realpath(__file__)))
        if os.path.exists(os.path.join(self.scripts,self.json_file)):
            try: self.data = json.load(open(os.path.join(self.scripts,self.json_file)))
            except: pass
        # Load the logo as well
        if os.path.exists(os.path.join(self.scripts,self.logo)):
            try: self.logo_img = tk.PhotoImage(file=os.path.join(self.scripts,self.logo))
            except: pass
        os.chdir(cwd)
        # Init the tkinter nonsense
        self.tk.title("Risk Of Rain 2 Unlocker")
        self.tk.minsize(width=900,height=400)

        # Add the weights
        for x in range(16):
            weight = 0 if x in (2,3,6,7,10,11,14,15) else 1
            self.tk.columnconfigure(x,weight=weight)
            weight = 0 if x in (0,1,2) else 0
            self.tk.rowconfigure(x,weight=weight)
        
        # Add the labels for the SteamID, Profile, Lunar Coins, and the Logo if possible
        self.s_label = tk.Label(self.tk,text="Steam ID:")
        self.s_label.grid(row=0,column=0,columnspan=4,padx=10,pady=10,sticky="ew")
        self.r_label = tk.Label(self.tk,text="Profile:")
        self.r_label.grid(row=0,column=4,columnspan=4,padx=10,pady=10,sticky="ew")
        self.c_label = tk.Label(self.tk,text="Lunar Coins (0-2147483647):")
        self.c_label.grid(row=0,column=8,columnspan=4,padx=10,pady=10,sticky="ew")
        if self.logo_img:
            self.c = tk.Label(self.tk, image=self.logo_img)
            self.c.grid(row=0,column=12,columnspan=4,rowspan=2,padx=10,pady=10,sticky="nswe")
        
        # Add the popup buttons and Entry field
        self.s_string = tk.StringVar(self.tk)
        self.s_list = []
        self.s_string.set("Select a Steam ID")
        self.s_menu = tk.OptionMenu(self.tk, self.s_string, ())
        self.s_menu.grid(row=1,column=0,columnspan=4,padx=10,pady=10,sticky="ew")
        self.r_string = tk.StringVar(self.tk)
        self.r_list = []
        self.r_string.set("Select a Profile")
        self.r_menu = tk.OptionMenu(self.tk, self.r_string, ())
        self.r_menu.grid(row=1,column=4,columnspan=4,padx=10,pady=10,sticky="ew")
        self.c_string = tk.StringVar()
        self.c_entry = tk.Spinbox(self.tk,from_=0,to=2147483647,validate="key",textvariable=self.c_string)
        self.c_entry.configure(validatecommand=(self.c_entry.register(self.validate_coins),'%P'))
        self.c_entry.grid(row=1,column=8,columnspan=4,padx=10,pady=10,sticky="ew")

        # Add the labels for the Items, Characters, Skills/Skins, and Achievements
        self.items_label = tk.Label(self.tk,text="Items:")
        self.items_label.grid(row=2,column=0,columnspan=4,padx=10,pady=10,sticky="ew")
        self.chars_label = tk.Label(self.tk,text="Characters:")
        self.chars_label.grid(row=2,column=4,columnspan=4,padx=10,pady=10,sticky="ew")
        self.skills_label = tk.Label(self.tk,text="Skills/Skins:")
        self.skills_label.grid(row=2,column=8,columnspan=4,padx=10,pady=10,sticky="ew")
        self.a_label = tk.Label(self.tk,text="Achievements:")
        self.a_label.grid(row=2,column=12,columnspan=4,padx=10,pady=10,sticky="ew")

        # Add the list boxes for Items, Characters, Skills/Skins, and Achievements
        self.item_scroll = tk.Scrollbar(self.tk, orient=tk.VERTICAL)
        self.item_scroll.grid(row=3,column=2,rowspan=4,sticky="nsew",padx=(0,10))
        self.item_box = tk.Listbox(self.tk,exportselection=False)
        self.item_box.grid(row=3,column=0,rowspan=4,columnspan=2,padx=(10,0),sticky="wens")
        self.item_box.config(yscrollcommand=self.item_scroll.set)
        self.char_scroll = tk.Scrollbar(self.tk, orient=tk.VERTICAL)
        self.char_scroll.grid(row=3,column=6,rowspan=4,sticky="nsew",padx=(0,10))
        self.char_box = tk.Listbox(self.tk,exportselection=False)
        self.char_box.grid(row=3,column=4,rowspan=4,columnspan=2,padx=(10,0),sticky="wens")
        self.char_box.config(yscrollcommand=self.char_scroll.set)
        self.char_box.bind("<<ListboxSelect>>",self.char_selected)
        self.skil_scroll = tk.Scrollbar(self.tk, orient=tk.VERTICAL)
        self.skil_scroll.grid(row=3,column=10,rowspan=4,sticky="nsew",padx=(0,10))
        self.skil_box = tk.Listbox(self.tk,exportselection=False)
        self.skil_box.grid(row=3,column=8,rowspan=4,columnspan=2,padx=(10,0),sticky="wens")
        self.skil_box.config(yscrollcommand=self.skil_scroll.set)
        self.achi_scroll = tk.Scrollbar(self.tk, orient=tk.VERTICAL)
        self.achi_scroll.grid(row=3,column=14,rowspan=4,sticky="nsew",padx=(0,10))
        self.achi_box = tk.Listbox(self.tk,exportselection=False)
        self.achi_box.config(yscrollcommand=self.achi_scroll.set)
        self.achi_box.grid(row=3,column=12,rowspan=4,columnspan=2,padx=(10,0),sticky="wens")

        # Add the combo boxes
        self.item_combo = ttk.Combobox(self.tk,values=[])
        self.item_combo.grid(row=8,column=0,columnspan=4,sticky="we",padx=10,pady=10)
        self.char_combo = ttk.Combobox(self.tk,values=[])
        self.char_combo.grid(row=8,column=4,columnspan=4,sticky="we",padx=10,pady=10)
        self.skil_combo = ttk.Combobox(self.tk,values=[])
        self.skil_combo.grid(row=8,column=8,columnspan=4,sticky="we",padx=10,pady=10)
        self.achi_combo = ttk.Combobox(self.tk,values=[])
        self.achi_combo.grid(row=8,column=12,columnspan=4,sticky="we",padx=10,pady=10)

        # Add the Unlock/Lock buttons
        self.item_unlock = tk.Button(self.tk,text="Unlock",command=self.unlock_item)
        self.item_unlock.grid(row=9,column=0,sticky="we",padx=10,pady=10)
        self.item_lock = tk.Button(self.tk,text="Lock",command=self.lock_item)
        self.item_lock.grid(row=9,column=1,sticky="we",padx=10,pady=10,columnspan=3)
        self.char_unlock = tk.Button(self.tk,text="Unlock",command=self.unlock_char)
        self.char_unlock.grid(row=9,column=4,sticky="we",padx=10,pady=10)
        self.char_lock = tk.Button(self.tk,text="Lock",command=self.lock_char)
        self.char_lock.grid(row=9,column=5,sticky="we",padx=10,pady=10,columnspan=3)
        self.skil_unlock = tk.Button(self.tk,text="Unlock",command=self.unlock_skil)
        self.skil_unlock.grid(row=9,column=8,sticky="we",padx=10,pady=10)
        self.skil_lock = tk.Button(self.tk,text="Lock",command=self.lock_skil)
        self.skil_lock.grid(row=9,column=9,sticky="we",padx=10,pady=10,columnspan=3)
        self.achi_unlock = tk.Button(self.tk,text="Unlock",command=self.unlock_achi)
        self.achi_unlock.grid(row=9,column=12,sticky="we",padx=10,pady=10)
        self.achi_lock = tk.Button(self.tk,text="Lock",command=self.lock_achi)
        self.achi_lock.grid(row=9,column=13,sticky="we",padx=10,pady=10,columnspan=3)

        # Add the Unlock All buttons
        self.item_unlock_all = tk.Button(self.tk,text="Unlock All",command=self.unlock_items)
        self.item_unlock_all.grid(row=10,column=0,sticky="we",padx=10,pady=10,columnspan=4)
        self.char_unlock_all = tk.Button(self.tk,text="Unlock All",command=self.unlock_chars)
        self.char_unlock_all.grid(row=10,column=4,sticky="we",padx=10,pady=10,columnspan=4)
        self.skil_unlock_all = tk.Button(self.tk,text="Unlock All",command=self.unlock_skils)
        self.skil_unlock_all.grid(row=10,column=8,sticky="we",padx=10,pady=10,columnspan=4)
        self.achi_unlock_all = tk.Button(self.tk,text="Unlock All",command=self.unlock_achis)
        self.achi_unlock_all.grid(row=10,column=12,sticky="we",padx=10,pady=10,columnspan=4)

        # Add the master lock/unlock buttons
        self.master_unlock = tk.Button(self.tk,text="UNLOCK EVERYTHING",command=self.unlock_everything)
        self.master_unlock.grid(row=11,column=0,sticky="we",padx=10,pady=10,columnspan=4)
        self.master_lock = tk.Button(self.tk,text="LOCK EVERYTHING",command=self.lock_everything)
        self.master_lock.grid(row=11,column=12,sticky="we",padx=10,pady=10,columnspan=4)

        # Let's gather the items in each stage
        self.stages = [
            [self.s_menu], # Stage 0
            [self.r_menu], # Stage 1
            [              # Stage 2
                self.c_entry,
                self.item_box,
                self.item_combo,
                self.item_unlock,
                self.item_lock,
                self.item_unlock_all,
                self.char_box,
                self.char_combo,
                self.char_unlock,
                self.char_lock,
                self.char_unlock_all,
                self.skil_box,
                self.skil_combo,
                self.skil_unlock,
                self.skil_lock,
                self.skil_unlock_all,
                self.achi_box,
                self.achi_combo,
                self.achi_unlock,
                self.achi_lock,
                self.achi_unlock_all,
                self.master_unlock,
                self.master_lock
            ]
        ]
        self.set_stage()

        if not self.id_list:
            self.tk.bell()
            mb.showerror("Missing Files","Could not find any ROR2 profiles!",parent=self.tk)
            exit(1)

        # Clear the Steam ID menu - and add all available IDs
        self.s_menu["menu"].delete(0,"end")
        for x in self.id_list:
            self.s_menu["menu"].add_command(label=x,command=lambda menu=self.s_menu, value=x, var=self.s_string: self.option_pick(menu,value,var))
        tk.mainloop()

    def save_profile(self):
        profile = self.get_current_profile()
        if not profile: return # Nothing to save
        # Ensure we have a backup first
        target_file = os.path.join(self.user_folders,profile["id"],self.settings_path,profile["file"])
        backup_file = os.path.join(self.user_folders,profile["id"],self.settings_path,profile["file"]+".bak")
        if not os.path.exists(backup_file):
            shutil.copyfile(target_file,backup_file)
        output_xml = ET.tostring(profile["root"],encoding="unicode")
        with open(target_file,"w") as f:
            f.write(self.xml_header+output_xml)

    def lock(self, element):
        profile = self.get_current_profile()
        if not profile: return
        # Let's walk the unlocks and remove any matches
        found = False
        parent = profile["root"].find("stats")
        for x in profile["root"].iter("unlock"):
            if x.text.lower() != element.lower(): continue
            # Found it - remove
            found = True
            parent.remove(x)
        return found

    def unlock(self, element):
        profile = self.get_current_profile()
        if not profile: return
        # Assume we typed a new one - let's add it.  Check if it exists first
        for x in profile["root"].iter("unlock"):
            if x.text.lower() == element.lower():
                # Found it - bail
                return False
        # If we got here - we should be able to add it as a child of the stats element
        a = profile["root"].find("stats")
        b = ET.SubElement(a,"unlock")
        b.text = element
        return True

    def lock_achievement(self, element):
        profile = self.get_current_profile()
        if not profile: return
        achis = profile["root"].find("achievementsList").text
        achis = achis.split() if achis else [] # Just in case it was None
        new_achis = []
        for x in achis:
            if x.lower() == element.lower():
                continue
            new_achis.append(x)
        if len(new_achis) != len(achis):
            a = profile["root"].find("achievementsList")
            a.text = " ".join(new_achis)
        return len(new_achis) == len(achis)

    def unlock_achievement(self, element):
        profile = self.get_current_profile()
        if not profile: return
        achis = profile["root"].find("achievementsList").text
        achis = achis.split() if achis else [] # Just in case it was None
        new_achis = []
        for x in achis:
            if x.lower() == element.lower():
                return False
        achis.append(element)
        a = profile["root"].find("achievementsList")
        a.text = " ".join(achis)
        return True

    def set_coins(self, coin_amount):
        profile = self.get_current_profile()
        if not profile: return
        # Got an int - set it
        coins = profile["root"].find("coins")
        coins.text = str(coin_amount)
        # Let's make sure we have a totalCollectedCoins value that is > 0
        collected_coins = profile["root"].find("totalCollectedCoins")
        # Set it to the number of coins we have
        collected_coins.text = str(coin_amount)
        self.save_profile()

    def validate_coins(self,value):
        try: value = int(value)
        except:
            self.tk.bell()
            return False
        if not 0 <= value <= 2147483647:
            self.tk.bell()
            return False
        self.set_coins(value)
        return True

    def get_current_profile(self):
        if not self.s_string.get() in self.id_list: return None
        return next((x for x in self.id_list[self.s_string.get()] if x["name"] == self.r_string.get()),None)

    def get_coins(self):
        try: return int(self.get_current_profile()["root"].find("coins").text)
        except: return 0

    def update_boxes(self, preserve_selection = True):
        # This is a helper method to gather our current selections from each box,
        # then update the items within, and retain the selection if possible.
        # If the current selection is no longer available, we just select the first
        # index.
        profile = self.get_current_profile()
        if not profile: return # Profile doesn't exist - bail
        # Let's do a preliminary save of the data as well
        self.save_profile()
        # Save the currents
        if preserve_selection:
            curr_item = self.item_box.get(self.item_box.curselection()) if self.item_box.curselection() != () else None
            curr_char = self.char_box.get(self.char_box.curselection()) if self.char_box.curselection() != () else None
            curr_skil = self.skil_box.get(self.skil_box.curselection()) if self.skil_box.curselection() != () else None
            curr_achi = self.achi_box.get(self.achi_box.curselection()) if self.achi_box.curselection() != () else None
        else:
            curr_item = curr_char = curr_skil = curr_achi = None
        # Remove the current items
        self.item_box.delete(0,tk.END)
        self.char_box.delete(0,tk.END)
        self.skil_box.delete(0,tk.END)
        self.achi_box.delete(0,tk.END)
        # Gather and walk the Item and Character unlocks
        unlocks = [x.text for x in profile["root"].iter("unlock")]
        items = [x for x in unlocks if x.lower().startswith("items.")]
        chars = [x for x in unlocks if x.lower().startswith("characters.")]
        achis = profile["root"].find("achievementsList").text
        achis = achis.split() if achis else [] # Just in case it was None
        for x in items: self.item_box.insert(tk.END,x[6:])
        for x in chars: self.char_box.insert(tk.END,x[11:])
        for x in achis: self.achi_box.insert(tk.END,x)
        # Auto-select the previous item of each box if exists - or the first if possible
        if len(items):
            index = next((x for x in range(self.item_box.size()) if self.item_box.get(x) == curr_item),0)
            self.item_box.selection_set(index)
            self.item_box.see(index)
        if len(chars):
            index = next((x for x in range(self.char_box.size()) if self.char_box.get(x) == curr_char),0)
            self.char_box.selection_set(index)
            self.char_box.see(index)
            # Update the current_character to avoid "forgetting"
            self.current_character = self.char_box.get(self.char_box.curselection()) if self.char_box.curselection() != () else None
        if len(achis):
            index = next((x for x in range(self.achi_box.size()) if self.achi_box.get(x) == curr_achi),0)
            self.achi_box.selection_set(index)
            self.achi_box.see(index)
        # Let's populate the Items and Characters combo boxes from our data
        self.item_combo["values"] = [x.split(".")[-1] for x in sorted(self.data.get("Items",[]))]
        self.char_combo["values"] = sorted(list(self.data.get("Characters",[])))
        self.skil_combo["values"] = []
        self.achi_combo["values"] = sorted(self.data.get("Achievements",[]))
        # Get the currently selected character if any
        curr_char = self.char_box.get(self.char_box.curselection()) if self.char_box.curselection() != () else None
        if not curr_char: return # Nothing more to do
        # Walk the applicable skills and select the prior one if possible
        skils = []
        for x in unlocks:
            if not x.lower().startswith(("skills.","skins.")): continue
            try: check_char = x.split(".")[1]
            except: continue
            if curr_char.lower().startswith(check_char.lower()):
                skils.append(x)
        for x in skils: self.skil_box.insert(tk.END,x)
        if len(skils):
            index = next((x for x in range(self.skil_box.size()) if self.skil_box.get(x) == curr_skil),0)
            self.skil_box.selection_set(index)
            self.skil_box.see(index)
        # Let's get any applicable unlocks for our current character
        self.skil_combo["values"] = sorted(self.data.get("Characters",{}).get(curr_char,{}).get("unlocks",[]))

    def option_pick(self, menu, value, var):
        if var.get() == value: return # Nothing to do
        var.set(value)
        if menu == self.s_menu:
            if self.s_string.get() == self.current_id: return # No change
            self.current_id = self.s_string.get()
            # Set the profile - and show the items/characters
            self.r_menu["menu"].delete(0,"end")
            for x in self.id_list[self.s_string.get()]:
                # self.s_menu["menu"].add_command(label=x,command=tk._setit(self.s_string,x))
                self.r_menu["menu"].add_command(label=x["name"],command=lambda menu=self.r_menu, value=x["name"], var=self.r_string: self.option_pick(menu,value,var))
            # Enable the profiles and stuff
            self.set_stage(1)
        elif menu == self.r_menu:
            profile = self.get_current_profile()
            if not profile or profile == self.current_profile: return
            self.current_profile = profile
            self.set_stage(2)
            # Load the lunar coin count
            self.c_string.set(self.get_coins())
            self.c_entry.selection_clear()
            self.c_entry.icursor(tk.END)
            # Update our Items, Characters, and Skills/Skins boxes
            self.update_boxes(preserve_selection=False)

    def set_stage(self, current_stage=0):
        # Walk all our stages, and disable anything with an index higher than our current stage
        for i,x in enumerate(self.stages):
            state = tk.DISABLED if i > current_stage else tk.NORMAL
            for y in x:
                y["state"] = state

    def button_press(self, event=None):
        return

    def unlock_item(self, event=None, item=None, update=True):
        prefix = "Items."
        curr = item if item else self.item_combo.get()
        if not curr: return # Nothing to unlock
        if not curr.startswith(prefix): curr = prefix+curr
        self.unlock(curr)
        if update: self.update_boxes()

    def unlock_items(self, event=None, update=True):
        for x in self.item_combo["values"]:
            self.unlock_item(item=x,update=False)
        if update: self.update_boxes()

    def lock_item(self, event=None, item=None, update=True):
        curr = item if item else self.item_box.get(self.item_box.curselection()) if self.item_box.curselection() != () else None
        if not curr: return
        self.lock("Items."+curr)
        if update: self.update_boxes()

    def lock_items(self, event=None, update=True):
        for x in range(self.item_box.size()):
            self.lock_item(item=self.item_box.get(x),update=False)
        if update: self.update_boxes()

    def unlock_char(self, event=None, item=None, update=True):
        prefix = "Characters."
        curr = item if item else self.char_combo.get()
        if not curr: return # Nothing to unlock
        if not curr.startswith(prefix): curr = prefix+curr
        self.unlock(curr)
        if update: self.update_boxes()

    def unlock_chars(self, event=None, update=True):
        for x in self.char_combo["values"]:
            self.unlock_char(item=x,update=False)
        if update: self.update_boxes()

    def lock_char(self, event=None, item=None, update=True):
        curr = item if item else self.char_box.get(self.char_box.curselection()) if self.char_box.curselection() != () else None
        if not curr: return
        self.lock("Characters."+curr)
        # Also lock all respective skills/skins for that char if our profile is valid
        profile = self.get_current_profile()
        if profile:
            unlocks = [x.text for x in profile["root"].iter("unlock")]
            for x in unlocks:
                if not x.lower().startswith(("skills.","skins.")): continue
                try: check_char = x.split(".")[1]
                except: continue
                if curr.lower().startswith(check_char.lower()):
                    self.lock_skil(item=x,update=False)
        if update: self.update_boxes()

    def lock_chars(self, event=None, update=True):
        for x in range(self.char_box.size()):
            self.lock_char(item=self.char_box.get(x),update=False)
        if update: self.update_boxes()

    def unlock_skil(self, event=None, item=None, update=True):
        curr = item if item else self.skil_combo.get()
        if not curr: return # Nothing to unlock
        self.unlock(curr)
        if update: self.update_boxes()

    def unlock_skils(self, event=None, update=True):
        for x in self.skil_combo["values"]:
            self.unlock_skil(item=x,update=False)
        if update: self.update_boxes()

    def lock_skil(self, event=None, item=None, update=True):
        curr = item if item else self.skil_box.get(self.skil_box.curselection()) if self.skil_box.curselection() != () else None
        if not curr: return
        self.lock(curr)
        if update: self.update_boxes()

    def lock_skils(self, event=None, update=True):
        for x in range(self.skil_box.size()):
            self.lock_skil(item=self.skil_box.get(x),update=False)
        if update: self.update_boxes()

    def unlock_achi(self, event=None, item=None, update=True):
        curr = item if item else self.achi_combo.get()
        if not curr: return # Nothing to unlock
        self.unlock_achievement(curr)
        if update: self.update_boxes()

    def unlock_achis(self, event=None, update=True):
        for x in self.achi_combo["values"]:
            self.unlock_achi(item=x,update=False)
        if update: self.update_boxes()

    def lock_achi(self, event=None, item=None, update=True):
        curr = item if item else self.achi_box.get(self.achi_box.curselection()) if self.achi_box.curselection() != () else None
        if not curr: return
        self.lock_achievement(curr)
        if update: self.update_boxes()

    def lock_achis(self, event=None, update=True):
        for x in range(self.achi_box.size()):
            self.lock_achi(item=self.achi_box.get(x),update=False)
        if update: self.update_boxes()

    def unlock_everything(self, event=None):
        # Unlock all characters and skills/skins
        for x in self.data.get("Characters",{}):
            self.unlock("Characters."+x)
            for y in self.data.get("Characters",{}).get(x,{}).get("unlocks",[]):
                self.unlock(y)
        # Unlock all items
        for x in self.data.get("Items",[]):
            self.unlock(x)
        # Unlock all achievements
        for x in self.data.get("Achievements",[]):
            self.unlock_achievement(x)
        # Update the boxes
        self.update_boxes()

    def lock_everything(self, event=None):
        profile = self.get_current_profile()
        if not profile: return # Can't iterate what we can't see
        unlocks = [x.text for x in profile["root"].iter("unlock")]
        for x in unlocks:
            if x.lower().startswith(("characters.","items.","skills.","skins.")):
                self.lock(x)
        # Lock the achievements
        a = profile["root"].find("achievementsList")
        a.text = ""
        self.update_boxes()

    def char_selected(self, event=None):
        w = event.widget if event else self.char_box
        current_character = w.get(w.curselection())
        if current_character == self.current_character: return # No change to selection
        self.current_character = current_character # Updated - now let's show applicable items
        profile = self.get_current_profile()
        if not profile: return
        unlocks = [x.text for x in profile["root"].iter("unlock")]
        # Walk the unlocks looking for "Skills." and "Skins." with the current char's prefix
        skils = []
        for x in unlocks:
            if not x.lower().startswith(("skills.","skins.")): continue
            try: check_char = x.split(".")[1]
            except: continue
            if current_character.lower().startswith(check_char.lower()):
                skils.append(x)
        self.skil_box.delete(0,tk.END)
        for x in skils:
            self.skil_box.insert(tk.END,x)
        if len(skils):
            self.skil_box.selection_set(0)
            self.skil_box.see(0)
        # Let's get any applicable unlocks for our current character
        self.skil_combo["values"] = sorted(self.data.get("Characters",{}).get(current_character,{}).get("unlocks",[]))

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
                        "root":root,
                        "name":name
                        })
        return self.id_list

if __name__ == '__main__':
    r = RORUnlock()
