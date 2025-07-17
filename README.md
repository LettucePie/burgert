# burgert

FOSS Arcade Game made in Godot 4

## Setup

1. Download or Compile Godot 4.3
2. Clone this repository
3. Open Godot 4.3, scan the cloned folder.
4. Open the Project within Godot.
5. Download Export Templates if you haven't already.
    - Editor -> Manage Export Templates
6. Export Builds.
    - Project -> Export
    - Export All or select a build-target and export just that one.
7. Run from `exports/`

### Portmaster

Everything within `exports/portmaster/burgert` is what you need for most portmaster configuration, where you put them on your handheld varies by cfw. To apply new changes Export to the Portmaster target, then copy the `exports/portmaster/arm64/burgert.pck` file over the `exports/portmaster/burgert/burgert/burgert.pck` file. This could be done more elegantly, I do not know how.

## Translation

Nodes that are group/tagged with `lang_text`, `lang_text_array`, `lang_image`, `lang_image_array` can be altered based on data placed within the language designations on the `lang/lang_master.json` file. The Scene `lang/multi_lang.tscn` contains the tools and functions to both organize and apply translations.

I have no experience with translation work, I only know English. I threw this together based on no educated standard, so I'm hoping it's not awful, but understand if it is.

The General Outline/Workflow I assumed for this was:
1. Mark nodes that should be translated with one of the group tags.
    - `lang_text` if it is a node with a `.text` property
    - `lang_text_array` if it is a node that contains one or more arrays of strings
    - `lang_image` if it is a node with a `.texture` property
    - `lang_image_array` if it is a node with contains one or more arrays of textures/sprites
2. Build a template by running the project with `MultiLang.build_template = true`.
    - It will get saved to the `MultiLang.save_target_dir` directory with the `MultiLang.save_target_name` filename `.json`
3. Edit the template file, replacing the `data2` entries with the relevant translation.
    - You can use Search/Find tools in your preferred Text Editor.
    - `"type": "text"` or `"OVERRIDE"` for example...
    - Try to use 639-2 Codes as the data header, replacing `"eng"` for example.
4. Copy the block of translated data into the `lang/lang_master.json` file, appended at the end after a comma.
5. Add the 639-2 code to the `MultiLang.supported_languages` array, and it's legible name to the `MultiLang.supported_languages_named` array at the same index/spot.
6. Test it by saving and running the game with `F5`, then go to Options -> Languages -> and hopefully your translation is there.
