# Access Code 2.2 Final Project Proposal

**Project Name: Shoutout**  
**Team Name: Team Shoutout**  
**Team Members: Jason Wang, Mesfin Mekonnen, Diana Elezaj,Varindra Hart**  

## The Problem 

Our project aims to build an application that will allow its' users to create, edit, compile and send videos.

Existing products in this sphere fall short on the last feature above, namely 'sending'. The apps we have researched so far only perform one or two of the features we plan to implement. 

 In surveying the App store, we could not find an application that currently implements all the features above. However, popular resources in the realm of video editing and merging include:

* [Video Meger] (https://itunes.apple.com/us/app/video-merger-free-combine/id880953154?mt=8) -  Easily merge videos on your device.  (free, iPhone and iPad).
* [Glide] (https://itunes.apple.com/us/app/glide-live-video-messenger/id588199307?mt=8) - Glide is the live video messaging app for people who want more personality and expression when communicating with those who know them best.
 
* [Tribute] (https://www.tribute.co/) - A “Tribute” is the perfect gift for any important occasion. It is a video montage created by a group ("The Tribe”) that comes together to share their appreciation, admiration and encouragement for a person they all care for.

Shoutout is a social collaboration platform, as such we envision our primary users to be kids as young as teenagers and adults as old as grandparents (realizing that we'll need a UI/UX that can appeal to this full age range). Our app aims to have a simplistic design, one that doesn't bombard the user with features or ads, but displays only the crutial elements they need to create videos, merge videos, send videos or invite friends.

## The Solution 

The project consists of two parts: hardware (the robot) and software (an Android-based environment to control robot movement with a graphical programming language, introducing the principles of programming to kids as they play).

 * Low-cost DIY robot (less than $40) that functions well and looks good. Built from open-source, easily acquired components with a simple, proven design.
 * Basic enough for a kid to put together in a weekend. The app will include an assembly walkthrough.
 * Both graphical + text-based programming interfaces to control the robot with an Android device. 
 * Designed for learning and growth. No upper limit for 'hackability'.

By building on Android, our project becomes accessible to the more than 1 billion Android users worldwide -- especially in markets where cost places existing robotics experimentation kits out of reach. Our experience at Access Code (and subsequent alignment with C4Q's mission and values) strongly informs our belief that lowering the financial barrier to hardware experimentation by 60% has significant, impactful value for the following groups:
- A child saving to purchase his/her own components
- Parent(s) with multiple children
- Teacher/school purchasing for students (electronics sold in bulk would actually reduce the cost per "kit" in this use case)
- Low-income families, whether they be American or in developing nations

Building the project around a physical object (the robot) captures the excitement and possibility of programming and blends "screen time" into a creative, hands-on activity with limitless possiblity.

Ultimately, we want to inspire the learning skills and confidence for kids to engage with the project -- and with all technology in their lives -- not just as users but as collaborators and creators.

#### Baseline features

The robot:
 * Built around a widely available open-source microcontroller ([Arduino](https://www.arduino.cc/)).
 * Forward, backward and rotational movement (2x [continuous rotation servos](https://learn.adafruit.com/adafruit-motor-selection-guide/continuous-rotation-servos)).
 * Chassis constructed from low-cost and/or recycled materials (e.g. cardboard - [example design we will use as our starting point](http://www.foxytronics.com/learn/robots/how-to-make-your-first-arduino-robot/parts)).
 * Battery powered and controlled via Bluetooth with an Android device ([existing library for Android <--> Arduino via Bluetooth](https://github.com/aron-bordin/Android-with-Arduino-Bluetooth)).
 * Simple and flexible design encourages user modifications: paint it, decorate it, add hardware mods.
 
The app:
 * Objective-C based iOS application.
 * Simple, graphical programming language/interface (think [Scratch](https://scratch.mit.edu/)) with native methods for controlling the robot.
  * [Google Blockly](https://developers.google.com/blockly/?hl=en) provides a 100% client-side, customizable library with tons of functionality built-in.
  * Wrapping series of long, potentially complex Arduino commands in one GUI element for the user.
  * 10 basic commands (move forward/backward/left/right, rotate n degrees, blink x color y times, etc.) to start, with flexibility to modify and expand the language/interface by creating new methods (see [Custom Blocks with Blockly](https://developers.google.com/blockly/custom-blocks/overview)).
 * Option for advanced users to move to a text-based environment.
 * Elegant, enjoyable + easy to use UI/UX.
 * On first launch, the user is presented with a guide on sourcing and building the robot. Features illustration, text and/or video instructions.

**[Project Resources](https://github.com/jaellysbales/access-robot/blob/master/resources.md)**

#### Bonus features

 * Simple web platform for sharing robot patterns + programs (Google Blockly enables this via [cloud storage](https://developers.google.com/blockly/installation/cloud-storage)).
 * Robot add-ons: lights, sensors, internet connectivity.
 * Translation to other spoken languages (e.g. Spanish).

### Wireframe
Please review wireframes [here](https://github.com/jaellysbales/access-robot/blob/master/wireframes/wireframes.md).

## Execution

#### Timeline

| Week | Date | Sprint | 
|----|----|---|
| Week 1 |Nov 3-8| Research: Submit project proposal (11/3). Create wireframes. Research about competitors. Do tutorials on AVFoundation. |
| Week 2 |Nov 9-15| Research II: Submit revised proposal (11/10). Begin experimenting with hardware and writing code to interface Android with hardware. Research programming environments for children. |
| Week 3 | Nov 16-22| Development I: Build Android-Hardware interface. Experiment with programming environment. Prototype graphical language. Experiment with robot design.|
| Week 4 | Nov 23-29| Development III: Enrich UI/UX. Build robot assembly walkthrough activity. Finalize app. |
| Week 5 | Nov 30-Dec 6| Testing I: Write tests and debug. Polish features for the second release. Implement bonuses. |
| Week 6 | Dec 8, 5pm | Final Demo Day at Google |

#### Team Member Responsibilities

**Mesfin:**

UI/UX - Wireframes of screens, storyboards of new user experience, sitemap to show activities that users have access to from each activity, maintaining consistent design feel through the app, working with programming language to decide how the interface is setup.

**Varindra:**

Creating a programming language to control the robot's movements - creating Scratch-like programming language that is an engaging but easy to understand, drag-and-drop interface on Android. Ensuring language is inline with robot's capabilities.

**Jason:**

Communication between Android and Arduino/robot - communication between Arduino and Android device through serial port, ensuring our programming language commands are properly transferred between hardware, possibly use a translator.

**Diana:**

Manages the team to ensure work is on track with timeline, rotates between jobs to help where needed, design of robot, will help with the communication between Arduino and Android, will help with programming language, parts are already ordered and should be here between Monday and Tuesday ([project hardware inventory](https://github.com/jaellysbales/access-robot/blob/master/hardware-list.md)).
