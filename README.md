### Cav_ranges is a modular framework for practice target ranges in Arma 3.
It allows you to setup a feature complete target range in just a few minutes.

![range](https://i.imgur.com/P0WqD4Y.png)

## Features

### Fully Modular Framework
Modular design allows multiple types of ranges to be configured and operated with common functionality.  

Current modules:
* **Popup Targets** - Animated targets are controlled via the scripts for traditional target ranges like rifle, pistol, and even grenade ranges.
* **Spawned Targets** - Targets are destroyed by the shooter and respawn, for example in an anti-tank range.

The common framework allows fast integration of new modules with completely different functionality, of which several are in development.

### Easy configuration
After some quick editor setup, all configuration is done via one function to create each range.

```
  "targets", //range type
  "Rifle Range", // title text
  r2", // range tag
  6, // lane count
  8, // targets per lane
  ...
  [38,30,23] // qualification tiers
```

### Automated Range Sequencing
Popup ranges become trivial to control. A minimal syntax of "what and how long" is all that's needed.

```
  ["Load your magazine",5],
  ["Assume a prone position and standby",3],-
  ["Range is hot!",1],
  [[8],5],
  [[2],5],
  [[6,4],5],
  [[3,5],5],
```

### Range User Interface
A fully featured display shows real time information about the range, including range messages, who's shooting and their score, and qualification awards once the range is complete.  

![range ui](https://i.imgur.com/R9RI2if.png)
