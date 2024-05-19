# Pally Power Lite

Conceptually and visually, the addon is based on [Pally Power Classic](https://www.curseforge.com/wow/addons/pally-power), but developed from scratch and simplified to the realities of a casual Cataclysm expansion. The addon is created as a minimalistic version of the original. Allows you to assign and track an Aura, Seal and Buff for yourself and party/raid members. Can be used by raid leader to assign Auras and Buffs for pallys in raid (who has the addon of course).

## Overlay

A small window with visual information about the assigned buffs and their current state. It always showing and only paladins will see it.

### Features

- Use the small anchor button on the left to lock/unlock changing position. Hold LMB on anchor and drag to move
- Scroll mouse wheel up/down above the three buttons to cycle through Auras(up one)/Seal (middle one)/Buffs(bottom one)
- Button will be green if you use correct Aura/Seal spell or red if not
- Bottom button will be green if all party/raid members have the selected buff, yellow if someone miss the buff and red if no one have
- And more, if someone miss the buff, you will see number of how much ppl
- Click on button to cast the buff

## Assignment

Click on minimap icon or slash command (/ppl or /pallipowerlite), to open party/raid assignment window. Here you and ppl from party/raid can change assignment for pally who has the addon.

### Features

- Shows count of members by his class in the party/raid
- Shows the pallys with addon, they role and number of talent points by spec
- Scroll mouse wheel up/down above the buttons of Aura or Buff to cycle and assign that
- Show up to 8 paladins (you own always show first)

## Credits and Additional Info

### Credits

[Here](https://www.curseforge.com/wow/addons/pally-power) you can find the original addon and its author **aznamir** on which this addon is based. The author is not considering supporting the original addon after WoTLK. Permission to create a lite version was received on the [official discord channel](https://discord.gg/M4G92wG).

### What have we lost compared to WoTLK (for now)

I don't mean the changes made by the Blizzards and what the paladins themselves lost. This is about the functionality that the addon has lost compared to its original version. Some things were eliminated because they are no longer relevant, some due to optimization, and some because I don’t have enough time to implementing them from scratch (included them in the TODO for the future... maybe... =))

- Distribution of assignment by class and class buttons in overlay (no need anymore - buff work on all party/raid members)
- Auto buff button (seriously?.. now need to click only one button)
- Normal blessing assignment (no more normal buffs)
- Macro integration (don't see a reason for implementing this)
- Free assignment option (yea yea.. i know - see the TODO)
- Skins and other frame options (see the TODO)

### TODO

A couple of things I might implement in the future

- Free assignment option
- Skins and other frame options
- Support more than 8 pallys in assignment window
- ???