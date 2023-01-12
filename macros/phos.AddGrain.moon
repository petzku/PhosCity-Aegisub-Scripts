export script_name = "Add Grain"
export script_description = "Add static and dynamic grain"
export script_version = "1.1.0"
export script_author = "PhosCity"
export script_namespace = "phos.AddGrain"

DependencyControl = require "l0.DependencyControl"
depctrl = DependencyControl{
  feed: "https://raw.githubusercontent.com/PhosCity/Aegisub-Scripts/main/DependencyControl.json",
  {
    {"a-mo.LineCollection", version: "1.3.0", url: "https: //github.com/TypesettingTools/Aegisub-Motion",
      feed: "https: //raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"},
    {"l0.ASSFoundation", version: "0.5.0", url: "https: //github.com/TypesettingTools/ASSFoundation",
      feed: "https: //raw.githubusercontent.com/TypesettingTools/ASSFoundation/master/DependencyControl.json"},
    {"l0.Functional", version: "0.6.0", url: "https://github.com/TypesettingTools/Functional",
      feed: "https://raw.githubusercontent.com/TypesettingTools/Functional/master/DependencyControl.json"},
    "Yutils"
  }
}
LineCollection, ASS, Functional, Yutils = depctrl\requireModules!
logger = depctrl\getLogger!
{:list} = Functional

--- Checks if the grain font is installed and informs the user
isGrainInstalled = ->
  isInstalled = false
  message = "It seems you have not installed grain font.
The script will proceed but will not look as intented unless you install the font.
You can install it from following link:
https://cdn.discordapp.com/attachments/425357202963038208/708726507173838958/grain.ttf"

  for font in *Yutils.decode.list_fonts!
    isInstalled = true if font.name == "Grain" and font.longname == "Grain Regular"
  logger\log message unless isInstalled


--- Randomize a character by returning any character among 0-9a-zA-z!"',.:;?
---@return string or integer
randomize = ->
  ascii = list.join [x for x = 48, 57], [x for x = 65, 90], [x for x = 97, 122], {33, 34, 39, 44, 46, 58, 59, 63}
  string.char ascii[math.random(1, #ascii)]

--- Main processing function
---@param mode string "dense" or "normal"
---@param sub table subtitle object
---@param sel table selected lines
main = (mode) ->
  (sub, sel) ->
    isGrainInstalled!

    lines = LineCollection sub, sel
    return if #lines.lines == 0

    lines\runCallback (lines, line, i) ->
      data = ASS\parse line

      -- Pure white layer
      data\callback ((section) -> section\replace "!!", randomize), ASS.Section.Text
      data\removeTags {"fontname", "outline", "shadow", "color1"}
      data\insertTags {ASS\createTag 'fontname', "Grain"}
      data\insertTags {ASS\createTag 'outline', 0}
      data\insertTags {ASS\createTag 'shadow', 0}
      data\insertTags {ASS\createTag 'color1', 255, 255, 255} 
      data\insertTags {ASS\createTag 'bold', 0} 
      if mode == "dense"
        data\removeTags {"color3", "color4", "alpha1", "alpha3"}
        data\insertTags {ASS\createTag 'color3', 255, 255, 255}
        data\insertTags {ASS\createTag 'color4', 255, 255, 255}
        data\insertTags {ASS\createTag 'alpha1', 254}
        data\insertTags {ASS\createTag 'alpha3', 255}
        data\replaceTags {ASS\createTag 'shadow', 0.01}
      data\cleanTags!
      lines\addLine ASS\createLine { line }

      -- Pure black layer
      data\callback ((section) -> section\replace "[^\\N]", randomize), ASS.Section.Text
      data\replaceTags {ASS\createTag 'color1', 0, 0, 0}
      if mode == "dense"
        data\replaceTags {ASS\createTag 'color3', 0, 0, 0}
        data\replaceTags {ASS\createTag 'color4', 0, 0, 0}
      data\commit!
    lines\replaceLines!
    lines\insertLines!

  
-- Register macros
depctrl\registerMacros({
  { "Add grain", "Add grain", main "normal" },
  { "Add dense grain", "Add dense grain", main "dense" },
})
