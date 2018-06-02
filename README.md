# cav_ranges
This modular framework allows rapid setup and configuration of multiple, fully featured practice target ranges in Arma 3.

![range](https://i.imgur.com/P0WqD4Y.png)

## Features

### Modular
Modular design allows ranges with differing core behavior to function within a common framework.  

Current modules:
* **Popup Target Range** - Animated targets are controlled via the scripts for traditional target ranges like rifle, pistol, and even grenade ranges.
* **Spawned Target Range** - Targets are destroyed by the shooter and respawn, for example in an anti-tank range.

The common framework allows fast integration of new modules with completely different functionality, several of which are in development.

### Easy configuration
After some quick editor setup, all configuration is done via one function's arguments at mission init.

```sqf
  "targets", //range type
  "Rifle Range", // title text
  "r2", // range tag
  6, // lane count
  8, // targets per lane
  ...
  [38,30,23] // qualification tiers
```

### Automated Range Sequencing  
Popup ranges become trivial to control. A minimal syntax of "what and how long" is all that's needed, but further control is offered, like playing sounds through range loudspeakers.  

```sqf
  ["Load your magazine",5],
  ["Assume a prone position and standby",3],
  ["Range is hot!",1,"FD_Course_Active_F"], // play "FD_Course_Active_F" sound
  [[8],5],
  [[2],5],
  [[6,4],5],
  [[3,5],5],
```

### Range User Interface
A real time display shows information about the range, including range instructions, who's shooting and their score, and qualification awards once the range is complete.  

![range ui](https://i.imgur.com/R9RI2if.png)

## Setup Guide
For detailed setup instructions, please see the [wiki](https://github.com/RaynorD/cav_ranges/wiki/Design-Your-Range-(createRange)).
