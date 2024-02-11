Learn godot using those lessons: https://www.youtube.com/watch?v=z23MQ2xad30&list=PLpp4UXjsd_VeN7FrIbk7suElcL3bm6eLB

But with some differences:

- use [StateChart](https://www.youtube.com/watch?v=E9h9VnbPGuw) to handle some states
- store player main data in PlayerManager instead of UI
- less usage of physical_process and more in states (try to use physical_process loop as least as possible)
- don't use animation for things not really related to animations
- some scene improvements like:
  - don't use inverted light, use normal. 
  - add some color tint in morning, night, evening
  - turn on torchs, make them animated


